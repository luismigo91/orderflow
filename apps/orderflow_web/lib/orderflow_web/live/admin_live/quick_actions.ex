defmodule OrderflowWeb.AdminLive.QuickActions do
  use OrderflowWeb, :live_view

  import Ecto.Query

  alias Orderflow.Orders
  alias Orderflow.Orders.Order
  alias Orderflow.Inventory
  alias Orderflow.AuditLog
  alias Orderflow.Repo

  @impl true
  def mount(_params, _session, socket) do
    stats = load_stats()
    {:ok, assign(socket, stats: stats, page_title: "Quick Actions")}
  end

  @impl true
  def handle_event("archive_all_delivered", _, socket) do
    user = socket.assigns.current_user

    {count, _} =
      Order
      |> where([o], o.status == :delivered)
      |> Repo.update_all(set: [archived: true])

    AuditLog.log_action(user.id, "bulk_archive", "orders", "all_delivered", %{
      count: count,
      status: "delivered"
    })

    {:noreply,
     socket
     |> put_flash(:info, "Archived #{count} delivered orders")
     |> assign(:stats, load_stats())}
  end

  @impl true
  def handle_event("check_inventory", _, socket) do
    alerts = Inventory.check_stock_levels()

    {:noreply,
     socket
     |> put_flash(:info, "Found #{length(alerts)} low stock items")
     |> assign(:stats, load_stats())}
  end

  @impl true
  def handle_event("clear_cache", _, socket) do
    Orderflow.Cache.clear()

    {:noreply,
     socket
     |> put_flash(:info, "Cache cleared")
     |> assign(:stats, load_stats())}
  end

  defp load_stats do
    %{
      pending_orders: length(Orders.list_orders_by_status(:pending)),
      cooking_orders: length(Orders.list_orders_by_status(:cooking)),
      ready_orders: length(Orders.list_orders_by_status(:ready)),
      low_stock_alerts: length(Inventory.list_unresolved_alerts()),
      total_orders_today:
        Orders.list_orders_by_date_range(
          NaiveDateTime.utc_now() |> NaiveDateTime.add(-86400),
          NaiveDateTime.utc_now()
        )
        |> length()
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">Quick Actions</h1>
      
    <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="bg-yellow-50 rounded-lg p-4 border border-yellow-200">
          <div class="text-3xl font-bold text-yellow-700">{@stats.pending_orders}</div>
          <div class="text-sm text-yellow-600">Pending Orders</div>
        </div>

        <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
          <div class="text-3xl font-bold text-blue-700">{@stats.cooking_orders}</div>
          <div class="text-sm text-blue-600">Cooking</div>
        </div>

        <div class="bg-green-50 rounded-lg p-4 border border-green-200">
          <div class="text-3xl font-bold text-green-700">{@stats.ready_orders}</div>
          <div class="text-sm text-green-600">Ready</div>
        </div>

        <div class="bg-red-50 rounded-lg p-4 border border-red-200">
          <div class="text-3xl font-bold text-red-700">{@stats.low_stock_alerts}</div>
          <div class="text-sm text-red-600">Low Stock Alerts</div>
        </div>
      </div>
      
    <!-- Action Buttons -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <button
          phx-click="archive_all_delivered"
          class="bg-purple-600 hover:bg-purple-700 text-white font-bold py-4 px-6 rounded-lg transition flex flex-col items-center gap-2"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"
            />
          </svg>
          <span>Archive All Delivered</span>
        </button>

        <button
          phx-click="check_inventory"
          class="bg-orange-600 hover:bg-orange-700 text-white font-bold py-4 px-6 rounded-lg transition flex flex-col items-center gap-2"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
            />
          </svg>
          <span>Check Inventory</span>
        </button>

        <button
          phx-click="clear_cache"
          class="bg-gray-600 hover:bg-gray-700 text-white font-bold py-4 px-6 rounded-lg transition flex flex-col items-center gap-2"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 10V3L4 14h7v7l9-11h-7z"
            />
          </svg>
          <span>Clear Cache</span>
        </button>
      </div>
    </div>
    """
  end
end
