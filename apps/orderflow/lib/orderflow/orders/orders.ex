defmodule Orderflow.Orders do
  @moduledoc """
  Contexto de gestión de pedidos y su ciclo de vida.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Orders.Order
  alias Orderflow.Orders.OrderItem
  alias Orderflow.Orders.OrderStatusLog
  alias Orderflow.Orders.OrderFSM
  alias Orderflow.Orders.SplitPayment
  alias Orderflow.Catalog

  def list_orders(opts \\ []) do
    Order
    |> preload([:order_items, :user, :assigned_user])
    |> maybe_filter_by_status(opts[:status])
    |> order_by([o], desc: o.inserted_at)
    |> Repo.all()
  end

  def list_orders_by_status(status) when is_list(status) do
    Order
    |> where([o], o.status in ^status)
    |> preload([:order_items, :user])
    |> order_by([o], asc: o.inserted_at)
    |> Repo.all()
  end

  def list_orders_by_status(status) do
    Order
    |> where([o], o.status == ^status)
    |> preload([:order_items, :user])
    |> order_by([o], asc: o.inserted_at)
    |> Repo.all()
  end

  def list_orders_by_status(status, opts) do
    Order
    |> where([o], o.status == ^status)
    |> maybe_filter_older_than(opts[:older_than])
    |> preload([:order_items, :user])
    |> order_by([o], asc: o.inserted_at)
    |> Repo.all()
  end

  def list_orders_by_date_range(start_date, end_date) do
    Order
    |> where([o], o.inserted_at >= ^start_date and o.inserted_at <= ^end_date)
    |> preload([:order_items, :user])
    |> order_by([o], desc: o.inserted_at)
    |> Repo.all()
  end

  def get_order!(id), do: Repo.get!(Order, id)
  def get_order(id), do: Repo.get(Order, id)

  def get_order_with_items!(id) do
    Order
    |> preload(order_items: :product, status_logs: [], user: [], assigned_user: [])
    |> Repo.get!(id)
  end

  def create_order(attrs, user_id) do
    items = attrs["items"] || attrs[:items] || []

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:order, fn _changes ->
      %Order{}
      |> Order.changeset(Map.merge(attrs, %{"user_id" => user_id}))
    end)
    |> Ecto.Multi.run(:items, fn _repo, %{order: order} ->
      create_order_items(order, items)
    end)
    |> Ecto.Multi.run(:total, fn _repo, %{order: order, items: _items} ->
      total = calculate_order_total(order.id)

      order
      |> Ecto.Changeset.change(total: total)
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{total: order}} ->
        order = get_order_with_items!(order.id)
        broadcast_order_change(order, "order_created")
        {:ok, order}

      {:error, _step, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def advance_status(%Order{} = order, to_status, changed_by, reason \\ nil) do
    case OrderFSM.validate_transition!(order.status, to_status) do
      :ok ->
        Ecto.Multi.new()
        |> Ecto.Multi.update(:order, fn _changes ->
          order
          |> Order.status_changeset(%{status: to_status})
        end)
        |> Ecto.Multi.insert(:log, fn %{order: updated_order} ->
          %OrderStatusLog{}
          |> OrderStatusLog.changeset(%{
            order_id: updated_order.id,
            from_status: order.status,
            to_status: to_status,
            changed_by: changed_by,
            reason: reason
          })
        end)
        |> Ecto.Multi.run(:stock, fn _repo, %{order: _updated_order} ->
          handle_stock_transition(order, to_status)
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{order: updated_order}} ->
            order = get_order_with_items!(updated_order.id)
            broadcast_order_change(order, "order_updated")
            {:ok, order}

          {:error, _step, changeset, _changes} ->
            {:error, changeset}
        end

      {:error, :invalid_transition, message} ->
        {:error, :invalid_transition, message}
    end
  end

  def cancel_order(%Order{} = order, reason, changed_by) do
    advance_status(order, :cancelled, changed_by, reason)
  end

  def assign_rider(%Order{} = order, rider_id) do
    order
    |> Ecto.Changeset.change(assigned_user_id: rider_id)
    |> Repo.update()
  end

  def list_status_logs(order_id) do
    OrderStatusLog
    |> where([l], l.order_id == ^order_id)
    |> order_by([l], desc: l.inserted_at)
    |> Repo.all()
  end

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status), do: where(query, [o], o.status == ^status)

  defp maybe_filter_older_than(query, nil), do: query

  defp maybe_filter_older_than(query, minutes) do
    cutoff = NaiveDateTime.utc_now() |> NaiveDateTime.add(-minutes, :minute)
    where(query, [o], o.updated_at < ^cutoff)
  end

  defp broadcast_order_change(order, event) do
    Phoenix.PubSub.broadcast(Orderflow.PubSub, "orders:lobby", %{
      event: event,
      order: order
    })

    Phoenix.PubSub.broadcast(Orderflow.PubSub, "order:#{order.id}", %{
      event: event,
      order: order
    })
  end

  defp create_order_items(_order, []), do: {:ok, []}

  defp create_order_items(order, items) do
    result =
      Enum.reduce_while(items, {:ok, []}, fn item_attrs, {:ok, acc} ->
        product = Catalog.get_product!(item_attrs["product_id"])

        item = %OrderItem{
          order_id: order.id,
          product_id: product.id,
          quantity: item_attrs["quantity"] || 1,
          unit_price: product.price,
          notes: item_attrs["notes"]
        }

        changeset = OrderItem.changeset(item, %{})

        case Repo.insert(changeset) do
          {:ok, inserted_item} -> {:cont, {:ok, [inserted_item | acc]}}
          {:error, changeset} -> {:halt, {:error, changeset}}
        end
      end)

    case result do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp calculate_order_total(order_id) do
    OrderItem
    |> where([i], i.order_id == ^order_id)
    |> select([i], sum(i.subtotal))
    |> Repo.one() || Decimal.new("0.00")
  end

  defp handle_stock_transition(order, :cooking) when order.status == :confirmed do
    items =
      OrderItem
      |> where([i], i.order_id == ^order.id)
      |> preload(:product)
      |> Repo.all()

    result =
      Enum.reduce_while(items, :ok, fn item, :ok ->
        case Catalog.decrement_stock(item.product, item.quantity) do
          {:ok, _} ->
            {:cont, :ok}

          {:error, :insufficient_stock} ->
            {:halt, {:error, :insufficient_stock, item.product.name}}
        end
      end)

    case result do
      :ok -> {:ok, nil}
      error -> error
    end
  end

  defp handle_stock_transition(order, :cancelled) when order.status == :cooking do
    items =
      OrderItem
      |> where([i], i.order_id == ^order.id)
      |> preload(:product)
      |> Repo.all()

    Enum.each(items, fn item ->
      Catalog.restore_stock(item.product, item.quantity)
    end)

    {:ok, nil}
  end

  defp handle_stock_transition(_order, _to_status), do: {:ok, nil}

  def get_split_payment!(id), do: Repo.get!(SplitPayment, id)
end
