defmodule OrderflowWeb.OrderTrackerLive.Index do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "order:#{id}")
    end

    order = Orders.get_order_with_items!(id)

    {:ok,
     socket
     |> assign(:order, order)
     |> assign(:page_title, "Seguimiento de Pedido #{id}")}
  end

  @impl true
  def handle_info(%{event: "order_updated", order: order}, socket) do
    {:noreply, assign(socket, :order, order)}
  end
end
