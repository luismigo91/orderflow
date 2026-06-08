defmodule OrderflowWeb.AdminLive.Monitoring do
  use OrderflowWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "monitoring:alerts")
    end

    {:ok,
     socket
     |> assign(:alerts, [])
     |> assign(:system_stats, get_system_stats())
     |> assign(:page_title, "Monitoring")}
  end

  @impl true
  def handle_info(%{event: "alert", alert: alert}, socket) do
    alerts = [alert | socket.assigns.alerts] |> Enum.take(50)
    {:noreply, assign(socket, :alerts, alerts)}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp get_system_stats do
    %{
      memory: :erlang.memory(:total) |> div(1024 * 1024),
      processes: length(Process.list()),
      uptime: :erlang.statistics(:wall_clock) |> elem(0) |> div(1000),
      atoms: :erlang.system_info(:atom_count)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-6">System Monitoring</h1>
      
    <!-- System Stats -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Memory</div>
          <div class="text-2xl font-bold text-blue-600">{@system_stats.memory} MB</div>
        </div>
        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Processes</div>
          <div class="text-2xl font-bold text-green-600">{@system_stats.processes}</div>
        </div>
        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Uptime</div>
          <div class="text-2xl font-bold text-purple-600">{@system_stats.uptime}s</div>
        </div>
        <div class="bg-white rounded-lg shadow p-4">
          <div class="text-sm text-gray-600">Atoms</div>
          <div class="text-2xl font-bold text-orange-600">{@system_stats.atoms}</div>
        </div>
      </div>
      
    <!-- Active Alerts -->
      <div class="bg-white rounded-lg shadow p-4">
        <h2 class="text-lg font-semibold mb-4">Active Alerts ({length(@alerts)})</h2>
        <div class="space-y-2">
          <%= for alert <- @alerts do %>
            <div class={"p-3 rounded-lg border-l-4 " <> alert_color(alert.severity)}>
              <div class="flex items-center justify-between">
                <span class="font-semibold">{alert.type}</span>
                <span class="text-sm text-gray-500">{alert.timestamp}</span>
              </div>
              <p class="text-sm mt-1">{alert.message}</p>
            </div>
          <% end %>
          <%= if @alerts == [] do %>
            <p class="text-gray-500 text-center py-4">No active alerts</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp alert_color(:critical), do: "bg-red-50 border-red-500 text-red-800"
  defp alert_color(:warning), do: "bg-yellow-50 border-yellow-500 text-yellow-800"
  defp alert_color(:info), do: "bg-blue-50 border-blue-500 text-blue-800"
  defp alert_color(_), do: "bg-gray-50 border-gray-500 text-gray-800"
end
