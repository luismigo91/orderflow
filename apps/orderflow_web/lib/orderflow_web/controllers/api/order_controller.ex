defmodule OrderflowWeb.Api.OrderController do
  use OrderflowWeb, :controller

  alias Orderflow.Orders

  action_fallback OrderflowWeb.FallbackController

  def index(conn, params) do
    status = params["status"] |> parse_status()
    orders = Orders.list_orders(status: status)
    render(conn, :index, orders: orders)
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order_with_items!(id)
    render(conn, :show, order: order)
  end

  def create(conn, %{"order" => order_params}) do
    user = conn.assigns.current_user

    with {:ok, order} <- Orders.create_order(order_params, user.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/orders/#{order.id}")
      |> render(:show, order: order)
    end
  end

  def update_status(conn, %{"id" => id, "status" => status}) do
    order = Orders.get_order!(id)
    user = conn.assigns.current_user
    reason = conn.params["reason"]

    case Orders.advance_status(order, String.to_atom(status), user.email, reason) do
      {:ok, order} -> render(conn, :show, order: order)
      {:error, :invalid_transition, message} -> {:error, :invalid_transition, message}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    user = conn.assigns.current_user
    reason = conn.params["reason"] || "Cancelled via API"

    with {:ok, _order} <- Orders.cancel_order(order, reason, user.email) do
      send_resp(conn, :no_content, "")
    end
  end

  defp parse_status(nil), do: nil
  defp parse_status(status), do: String.to_atom(status)
end
