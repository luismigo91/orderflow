defmodule OrderflowWeb.AdminLive.DashboardV2 do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders
  alias Orderflow.Catalog
  alias Orderflow.Accounts
  alias Orderflow.Inventory

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "orders:lobby")
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "admin:alerts")
      :timer.send_interval(5_000, self(), :refresh_metrics)
    end

    {:ok,
     socket
     |> assign(:page_title, "Real-time Dashboard")
     |> load_metrics()}
  end

  @impl true
  def handle_info(:refresh_metrics, socket) do
    {:noreply, load_metrics(socket)}
  end

  @impl true
  def handle_info(%{event: event}, socket) when event in ["order_created", "order_updated"] do
    {:noreply, load_metrics(socket)}
  end

  @impl true
  def handle_info(%{type: :stuck_order, order: _order}, socket) do
    {:noreply,
     socket
     |> put_flash(:warning, "Stuck order detected!")
     |> load_metrics()}
  end

  @impl true
  def handle_info(%{type: :low_stock, products: products}, socket) do
    {:noreply,
     socket
     |> put_flash(:warning, "#{length(products)} products with low stock!")
     |> load_metrics()}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp load_metrics(socket) do
    orders = Orders.list_orders()

    metrics = %{
      total_orders: length(orders),
      pending: length(Enum.filter(orders, &(&1.status == :pending))),
      cooking: length(Enum.filter(orders, &(&1.status == :cooking))),
      ready: length(Enum.filter(orders, &(&1.status == :ready))),
      delivering: length(Enum.filter(orders, &(&1.status == :delivering))),
      delivered: length(Enum.filter(orders, &(&1.status == :delivered))),
      cancelled: length(Enum.filter(orders, &(&1.status == :cancelled))),
      total_products: length(Catalog.list_products()),
      active_users: length(Accounts.list_active_users()),
      low_stock: length(Inventory.list_unresolved_alerts()),
      revenue_today: calculate_today_revenue(orders),
      avg_order_value: calculate_avg_order(orders),
      system_health: :healthy,
      last_updated: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    assign(socket, :metrics, metrics)
  end

  defp calculate_today_revenue(orders) do
    today = Date.utc_today()

    orders
    |> Enum.filter(fn o ->
      NaiveDateTime.to_date(o.inserted_at) == today and
        o.status in [:delivered, :ready]
    end)
    |> Enum.map(& &1.total)
    |> Enum.reduce(Decimal.new("0.00"), &Decimal.add/2)
  end

  defp calculate_avg_order(orders) do
    case length(orders) do
      0 ->
        Decimal.new("0.00")

      n ->
        total = Enum.map(orders, & &1.total) |> Enum.reduce(Decimal.new("0.00"), &Decimal.add/2)
        Decimal.div(total, Decimal.new(n))
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-bold">Real-time Dashboard</h1>
        <div class="flex items-center gap-2">
          <span class="relative flex h-3 w-3">
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75">
            </span>
            <span class="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
          </span>
          <span class="text-sm text-gray-600">Live • {@metrics.last_updated}</span>
        </div>
      </div>
      
    <!-- KPI Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-lg shadow p-4 border-l-4 border-blue-500">
          <div class="text-sm text-gray-600">Total Orders</div>
          <div class="text-3xl font-bold text-blue-600">{@metrics.total_orders}</div>
        </div>
        <div class="bg-white rounded-lg shadow p-4 border-l-4 border-green-500">
          <div class="text-sm text-gray-600">Today's Revenue</div>
          <div class="text-3xl font-bold text-green-600">${@metrics.revenue_today}</div>
        </div>
        <div class="bg-white rounded-lg shadow p-4 border-l-4 border-purple-500">
          <div class="text-sm text-gray-600">Avg Order</div>
          <div class="text-3xl font-bold text-purple-600">${@metrics.avg_order_value}</div>
        </div>
        <div class="bg-white rounded-lg shadow p-4 border-l-4 border-orange-500">
          <div class="text-sm text-gray-600">Active Users</div>
          <div class="text-3xl font-bold text-orange-600">{@metrics.active_users}</div>
        </div>
      </div>
      
    <!-- Status Pipeline -->
      <div class="bg-white rounded-lg shadow p-6 mb-6">
        <h2 class="text-lg font-semibold mb-4">Order Pipeline</h2>
        <div class="flex items-center justify-between">
          <%= for {status, count, color} <- [
            {"Pending", @metrics.pending, "bg-yellow-500"},
            {"Cooking", @metrics.cooking, "bg-blue-500"},
            {"Ready", @metrics.ready, "bg-green-500"},
            {"Delivering", @metrics.delivering, "bg-purple-500"},
            {"Delivered", @metrics.delivered, "bg-gray-500"},
            {"Cancelled", @metrics.cancelled, "bg-red-500"}
          ] do %>
            <div class="flex flex-col items-center gap-2">
              <div class={"w-16 h-16 rounded-full flex items-center justify-center text-white font-bold text-xl " <> color}>
                {count}
              </div>
              <span class="text-sm text-gray-600">{status}</span>
            </div>
          <% end %>
        </div>
      </div>
      
    <!-- Alerts -->
      <%= if @metrics.low_stock > 0 do %>
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <div class="flex items-center gap-2">
            <svg class="w-5 h-5 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
            <span class="font-semibold text-yellow-800">
              {@metrics.low_stock} products with low stock
            </span>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
