defmodule OrderflowWeb.AdminLive.Dashboard do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders
  alias Orderflow.Metrics

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "orders:lobby")
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "admin:alerts")
    end

    metrics = Metrics.Collector.get_dashboard_metrics()

    active_orders =
      Orders.list_orders_by_status([:pending, :confirmed, :cooking, :ready, :delivering])

    {:ok,
     socket
     |> assign(:metrics, metrics)
     |> assign(:active_orders, active_orders)
     |> assign(:alerts, [])
     |> assign(:page_title, "Dashboard")}
  end

  @impl true
  def handle_info(%{event: "order_updated"}, socket) do
    metrics = Metrics.Collector.get_dashboard_metrics()

    active_orders =
      Orders.list_orders_by_status([:pending, :confirmed, :cooking, :ready, :delivering])

    {:noreply,
     socket
     |> assign(:metrics, metrics)
     |> assign(:active_orders, active_orders)}
  end

  @impl true
  def handle_info(%{type: :stuck_order, order: order}, socket) do
    alerts = [order | socket.assigns.alerts] |> Enum.take(10)
    {:noreply, assign(socket, :alerts, alerts)}
  end
end
