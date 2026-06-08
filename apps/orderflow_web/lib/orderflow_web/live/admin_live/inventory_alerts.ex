defmodule OrderflowWeb.AdminLive.InventoryAlerts do
  use OrderflowWeb, :live_view

  alias Orderflow.Inventory

  @impl true
  def mount(_params, _session, socket) do
    alerts = Inventory.list_unresolved_alerts()
    {:ok, assign(socket, alerts: alerts, page_title: "Inventory Alerts")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Inventory Alerts</h1>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full text-left">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-4 py-2">Product</th>
              <th class="px-4 py-2">Current Stock</th>
              <th class="px-4 py-2">Threshold</th>
              <th class="px-4 py-2">Alerted At</th>
              <th class="px-4 py-2">Actions</th>
            </tr>
          </thead>
          <tbody>
            <%= for alert <- @alerts do %>
              <tr class="border-b">
                <td class="px-4 py-2">{alert.product.name}</td>
                <td class="px-4 py-2 text-red-600 font-bold">{alert.current_stock}</td>
                <td class="px-4 py-2">{alert.threshold}</td>
                <td class="px-4 py-2">{alert.inserted_at}</td>
                <td class="px-4 py-2">
                  <button
                    phx-click="resolve"
                    phx-value-id={alert.id}
                    class="text-green-600 hover:text-green-800"
                  >
                    Mark Resolved
                  </button>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>

        <%= if Enum.empty?(@alerts) do %>
          <p class="p-4 text-gray-500">No unresolved alerts. All stock levels are healthy.</p>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("resolve", %{"id" => id}, socket) do
    case Inventory.resolve_alert(String.to_integer(id)) do
      {:ok, _} ->
        alerts = Inventory.list_unresolved_alerts()
        {:noreply, assign(socket, alerts: alerts)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to resolve alert")}
    end
  end
end
