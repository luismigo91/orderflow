defmodule OrderflowWeb.AdminLive.Analytics do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders
  alias Orderflow.Catalog
  alias Orderflow.Accounts

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "orders:lobby")
      :timer.send_interval(30_000, self(), :refresh_metrics)
    end

    socket =
      socket
      |> assign(:page_title, "Analytics Dashboard")
      |> load_metrics()

    {:ok, socket}
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
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp load_metrics(socket) do
    orders = Orders.list_orders()
    today = NaiveDateTime.utc_now() |> NaiveDateTime.to_date()

    today_orders =
      Enum.filter(orders, fn o ->
        NaiveDateTime.to_date(o.inserted_at) == today
      end)

    metrics = %{
      total_orders: length(orders),
      today_orders: length(today_orders),
      today_revenue: calculate_revenue(today_orders),
      pending_orders: length(Enum.filter(orders, &(&1.status == :pending))),
      cooking_orders: length(Enum.filter(orders, &(&1.status == :cooking))),
      ready_orders: length(Enum.filter(orders, &(&1.status == :ready))),
      delivered_orders: length(Enum.filter(orders, &(&1.status == :delivered))),
      cancelled_orders: length(Enum.filter(orders, &(&1.status == :cancelled))),
      total_products: length(Catalog.list_products()),
      active_users: length(Accounts.list_active_users()),
      avg_order_value: calculate_avg_order_value(orders),
      top_products: get_top_products(orders),
      orders_by_hour: get_orders_by_hour(today_orders)
    }

    assign(socket, :metrics, metrics)
  end

  defp calculate_revenue(orders) do
    orders
    |> Enum.map(& &1.total)
    |> Enum.reduce(Decimal.new("0.00"), &Decimal.add/2)
  end

  defp calculate_avg_order_value([]), do: Decimal.new("0.00")

  defp calculate_avg_order_value(orders) do
    total = calculate_revenue(orders)
    count = length(orders)
    Decimal.div(total, Decimal.new(count))
  end

  defp get_top_products(orders) do
    orders
    |> Enum.flat_map(& &1.order_items)
    |> Enum.group_by(& &1.product.name)
    |> Enum.map(fn {name, items} -> {name, length(items)} end)
    |> Enum.sort_by(fn {_, count} -> count end, :desc)
    |> Enum.take(5)
  end

  defp get_orders_by_hour(orders) do
    orders
    |> Enum.group_by(fn o -> o.inserted_at.hour end)
    |> Enum.map(fn {hour, items} -> {hour, length(items)} end)
    |> Enum.sort_by(fn {hour, _} -> hour end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">Analytics Dashboard</h1>
      
    <!-- KPI Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Today's Orders</div>
          <div class="text-3xl font-bold text-blue-600">{@metrics.today_orders}</div>
        </div>

        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Today's Revenue</div>
          <div class="text-3xl font-bold text-green-600">${@metrics.today_revenue}</div>
        </div>

        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Avg Order Value</div>
          <div class="text-3xl font-bold text-purple-600">${@metrics.avg_order_value}</div>
        </div>

        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Active Users</div>
          <div class="text-3xl font-bold text-orange-600">{@metrics.active_users}</div>
        </div>
      </div>
      
    <!-- Order Status Breakdown -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div class="bg-white rounded-lg shadow p-4">
          <h2 class="text-lg font-semibold mb-4">Order Status</h2>
          <div class="space-y-2">
            <%= for {status, count, color} <- [
              {"Pending", @metrics.pending_orders, "bg-yellow-500"},
              {"Cooking", @metrics.cooking_orders, "bg-blue-500"},
              {"Ready", @metrics.ready_orders, "bg-green-500"},
              {"Delivered", @metrics.delivered_orders, "bg-gray-500"},
              {"Cancelled", @metrics.cancelled_orders, "bg-red-500"}
            ] do %>
              <div class="flex items-center gap-2">
                <div class={"w-3 h-3 rounded-full " <> color}></div>
                <span class="text-sm flex-1">{status}</span>
                <span class="font-bold">{count}</span>
              </div>
            <% end %>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-4">
          <h2 class="text-lg font-semibold mb-4">Top Products</h2>
          <div class="space-y-2">
            <%= for {name, count} <- @metrics.top_products do %>
              <div class="flex items-center gap-2">
                <span class="text-sm flex-1">{name}</span>
                <div class="flex-1 bg-gray-200 rounded-full h-2">
                  <div class="bg-blue-500 h-2 rounded-full" style={"width: #{min(count * 10, 100)}%"}>
                  </div>
                </div>
                <span class="text-sm font-bold">{count}</span>
              </div>
            <% end %>
            <%= if @metrics.top_products == [] do %>
              <p class="text-gray-400 text-sm">No data available</p>
            <% end %>
          </div>
        </div>
      </div>
      
    <!-- Orders by Hour -->
      <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-lg font-semibold mb-4">Orders by Hour (Today)</h2>
        <div class="flex items-end gap-1 h-32">
          <%= for hour <- 0..23 do %>
            <% count = @metrics.orders_by_hour[hour] || 0 %>
            <div class="flex-1 flex flex-col items-center gap-1">
              <div
                class="w-full bg-blue-500 rounded-t transition-all duration-500"
                style={"height: #{max(count * 20, 4)}px"}
              >
              </div>
              <span class="text-xs text-gray-500">{String.pad_leading(to_string(hour), 2, "0")}</span>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
