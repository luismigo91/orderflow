defmodule OrderflowWeb.AdminLive.Shifts do
  use OrderflowWeb, :live_view

  alias Orderflow.Shifts

  @impl true
  def mount(_params, _session, socket) do
    shifts = Shifts.list_shifts()
    {:ok, assign(socket, shifts: shifts, page_title: "Staff Shifts")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Staff Shifts</h1>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-100">
            <tr>
              <th class="p-2">Staff</th>
              <th class="p-2">Date</th>
              <th class="p-2">Start</th>
              <th class="p-2">End</th>
              <th class="p-2">Role</th>
              <th class="p-2">Status</th>
            </tr>
          </thead>
          <tbody>
            <%= for shift <- @shifts do %>
              <tr class="border-b">
                <td class="p-2">{shift.user && shift.user.name}</td>
                <td class="p-2">{shift.date}</td>
                <td class="p-2">{shift.start_time}</td>
                <td class="p-2">{shift.end_time}</td>
                <td class="p-2">{shift.role}</td>
                <td class="p-2">
                  <span class={"px-2 py-1 rounded text-sm capitalize #{status_color(shift.status)}"}>
                    {shift.status}
                  </span>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_color(:scheduled), do: "bg-blue-100 text-blue-800"
  defp status_color(:confirmed), do: "bg-green-100 text-green-800"
  defp status_color(:completed), do: "bg-gray-100 text-gray-800"
  defp status_color(:cancelled), do: "bg-red-100 text-red-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"
end
