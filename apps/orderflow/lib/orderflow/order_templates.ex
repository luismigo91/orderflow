defmodule Orderflow.OrderTemplates do
  @moduledoc """
  Context for order templates (quick reorder).
  """
  import Ecto.Query

  alias Orderflow.Orders.Order
  alias Orderflow.Orders.OrderItem
  alias Orderflow.Repo

  @doc """
  Create a template from an existing order.
  """
  def create_template_from_order(order_id, template_name) do
    order =
      Order
      |> preload([:order_items])
      |> Repo.get!(order_id)

    template_items =
      Enum.map(order.order_items, fn item ->
        %{
          "product_id" => item.product_id,
          "quantity" => item.quantity,
          "notes" => item.notes
        }
      end)

    %{
      name: template_name,
      customer_name: order.customer_name,
      customer_phone: order.customer_phone,
      items: template_items,
      notes: order.notes
    }
  end

  @doc """
  Get frequent items for a user (top 5 most ordered).
  """
  def get_frequent_items(user_id) do
    OrderItem
    |> join(:inner, [oi], o in Order, on: oi.order_id == o.id)
    |> where([_, o], o.user_id == ^user_id)
    |> group_by([oi], oi.product_id)
    |> select([oi], %{product_id: oi.product_id, count: count(oi.id)})
    |> order_by([oi], desc: count(oi.id))
    |> limit(5)
    |> Repo.all()
  end

  @doc """
  Get last order for a user.
  """
  def get_last_order(user_id) do
    Order
    |> where([o], o.user_id == ^user_id)
    |> order_by(desc: :inserted_at)
    |> preload([:order_items])
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Reorder from last order.
  """
  def reorder_last(order_params, user_id) do
    case get_last_order(user_id) do
      nil ->
        {:error, :no_previous_orders}

      last_order ->
        new_order_params =
          Map.merge(order_params, %{
            "customer_name" => last_order.customer_name,
            "customer_phone" => last_order.customer_phone,
            "items" =>
              Enum.map(last_order.order_items, fn item ->
                %{
                  "product_id" => item.product_id,
                  "quantity" => item.quantity
                }
              end)
          })

        Orderflow.Orders.create_order(new_order_params, user_id)
    end
  end
end
