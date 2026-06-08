defmodule OrderflowWeb.AdminLive.KitchenMetrics do
  use OrderflowWeb, :live_view

  alias Orderflow.Kitchen

  @impl true
  def mount(_params, _session, socket) do
    metrics = Kitchen.list_metrics()
    avg_time = Kitchen.average_prep_time()
    throughput = Kitchen.throughput_by_hour()

    {:ok,
     assign(socket,
       metrics: metrics,
       avg_time: avg_time,
       throughput: throughput,
       page_title: "Kitchen Metrics"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Kitchen Efficiency Metrics</h1>

      <div class="grid grid-cols-2 gap-4 mb-6">
        <div class="p-4 bg-orange-50 rounded-lg">
          <div class="text-3xl font-bold text-orange-600">{Float.round(@avg_time, 1)}</div>
          <div class="text-sm text-gray-600">Avg Prep Time (min)</div>
        </div>
        <div class="p-4 bg-purple-50 rounded-lg">
          <div class="text-3xl font-bold text-purple-600">{length(@metrics)}</div>
          <div class="text-sm text-gray-600">Orders Tracked</div>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-lg font-bold mb-2">Throughput by Hour</h2>
        <div class="flex gap-2">
          <%= for item <- @throughput do %>
            <div class="p-2 bg-blue-100 rounded text-center">
              <div class="font-bold">{item.hour}:00</div>
              <div class="text-sm">{item.count} orders</div>
            </div>
          <% end %>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-100">
            <tr>
              <th class="p-2">Order</th>
              <th class="p-2">Total Minutes</th>
              <th class="p-2">Items</th>
              <th class="p-2">Bottleneck</th>
            </tr>
          </thead>
          <tbody>
            <%= for metric <- @metrics do %>
              <tr class="border-b">
                <td class="p-2">#{metric.order_id}</td>
                <td class="p-2">{metric.total_minutes} min</td>
                <td class="p-2">{metric.items_count}</td>
                <td class="p-2 capitalize">{metric.bottleneck_stage}</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
