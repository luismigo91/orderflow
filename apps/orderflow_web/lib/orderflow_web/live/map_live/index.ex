defmodule OrderflowWeb.MapLive.Index do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(5000, :update_positions)
    end

    orders = Orders.list_orders_by_status(:delivering)

    {:ok,
     socket
     |> assign(:orders, orders)
     |> assign(:page_title, "Mapa de Delivery")}
  end

  @impl true
  def handle_info(:update_positions, socket) do
    orders = Orders.list_orders_by_status(:delivering)
    {:noreply, assign(socket, :orders, orders)}
  end
end
