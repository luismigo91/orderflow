defmodule OrderflowWeb.KitchenLive.Index do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "orders:lobby")
    end

    orders = Orders.list_orders_by_status([:cooking, :ready])

    {:ok,
     socket
     |> assign(:orders, orders)
     |> assign(:page_title, "Cocina")}
  end

  @impl true
  def handle_info(%{event: "order_updated"}, socket) do
    orders = Orders.list_orders_by_status([:cooking, :ready])
    {:noreply, assign(socket, :orders, orders)}
  end

  @impl true
  def handle_event("advance_status", %{"id" => id, "status" => status}, socket) do
    order = Orders.get_order!(id)
    user = socket.assigns.current_user

    case Orders.advance_status(order, String.to_atom(status), user.email) do
      {:ok, _order} ->
        {:noreply, put_flash(socket, :info, "Pedido #{id} actualizado")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Error al actualizar pedido")}
    end
  end
end
