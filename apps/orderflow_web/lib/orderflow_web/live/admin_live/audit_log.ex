defmodule OrderflowWeb.AdminLive.AuditLog do
  use OrderflowWeb, :live_view

  alias Orderflow.AuditLog

  @impl true
  def mount(_params, _session, socket) do
    entries = AuditLog.list_entries(50)
    {:ok, assign(socket, entries: entries, page_title: "Audit Log")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Audit Log</h1>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full text-left text-sm">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-4 py-2">Time</th>
              <th class="px-4 py-2">User</th>
              <th class="px-4 py-2">Action</th>
              <th class="px-4 py-2">Resource</th>
              <th class="px-4 py-2">Details</th>
            </tr>
          </thead>
          <tbody>
            <%= for entry <- @entries do %>
              <tr class="border-b">
                <td class="px-4 py-2">{entry.inserted_at}</td>
                <td class="px-4 py-2">{entry.user.name}</td>
                <td class="px-4 py-2">
                  <span class={badge_class(entry.action)}>
                    {entry.action}
                  </span>
                </td>
                <td class="px-4 py-2">{entry.resource_type} #{entry.resource_id}</td>
                <td class="px-4 py-2">
                  <%= if map_size(entry.metadata) > 0 do %>
                    <pre class="text-xs bg-gray-100 p-1 rounded"><%= Jason.encode!(entry.metadata) %></pre>
                  <% else %>
                    -
                  <% end %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>

        <%= if Enum.empty?(@entries) do %>
          <p class="p-4 text-gray-500">No audit entries found.</p>
        <% end %>
      </div>
    </div>
    """
  end

  defp badge_class("create"), do: "bg-green-100 text-green-800 px-2 py-1 rounded"
  defp badge_class("update"), do: "bg-blue-100 text-blue-800 px-2 py-1 rounded"
  defp badge_class("delete"), do: "bg-red-100 text-red-800 px-2 py-1 rounded"
  defp badge_class(_), do: "bg-gray-100 text-gray-800 px-2 py-1 rounded"
end
