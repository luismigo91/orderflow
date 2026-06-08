defmodule OrderflowWeb.Api.V1.OrderController do
  use OrderflowWeb, :controller

  alias Orderflow.Orders
  alias Orderflow.Pagination

  def index(conn, params) do
    cursor = params["cursor"]
    limit = String.to_integer(params["limit"] || "20")

    {orders, next_cursor, has_more} =
      Orders.Order
      |> Pagination.paginate(cursor, limit)

    meta = Pagination.metadata(orders, next_cursor, has_more)

    conn
    |> put_status(200)
    |> json(%{
      data: Enum.map(orders, &order_json/1),
      pagination: meta
    })
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order_with_items!(id)
    json(conn, order_json(order))
  end

  def create(conn, params) do
    user = conn.assigns.current_user

    case Orders.create_order(params, user.id) do
      {:ok, order} ->
        conn
        |> put_status(201)
        |> json(order_json(order))

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update_status(conn, %{"id" => id, "status" => status}) do
    order = Orders.get_order!(id)
    user = conn.assigns.current_user

    case Orders.advance_status(order, String.to_atom(status), user.email) do
      {:ok, updated} ->
        json(conn, order_json(updated))

      {:error, :invalid_transition, message} ->
        conn
        |> put_status(422)
        |> json(%{error: message})
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    case Orders.delete_order(order) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  defp order_json(order) do
    %{
      id: order.id,
      customer_name: order.customer_name,
      customer_phone: order.customer_phone,
      total: order.total,
      status: order.status,
      notes: order.notes,
      items:
        Enum.map(order.order_items || [], fn item ->
          %{
            product_id: item.product_id,
            quantity: item.quantity,
            unit_price: item.unit_price,
            subtotal: item.subtotal
          }
        end),
      inserted_at: order.inserted_at,
      updated_at: order.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r/%{(\w+)}/, msg, fn _, key ->
        to_string(Keyword.get(opts, String.to_atom(key), ""))
      end)
    end)
  end
end
