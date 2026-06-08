defmodule OrderflowWeb.AdminLive.Reservations do
  use OrderflowWeb, :live_view

  alias Orderflow.Tables

  @impl true
  def mount(_params, _session, socket) do
    reservations = Tables.list_reservations()
    {:ok, assign(socket, reservations: reservations, page_title: "Reservations")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Reservations</h1>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-100">
            <tr>
              <th class="p-2">Customer</th>
              <th class="p-2">Table</th>
              <th class="p-2">Party</th>
              <th class="p-2">Date & Time</th>
              <th class="p-2">Status</th>
            </tr>
          </thead>
          <tbody>
            <%= for reservation <- @reservations do %>
              <tr class="border-b">
                <td class="p-2">{reservation.customer_name}</td>
                <td class="p-2">{reservation.table && reservation.table.number}</td>
                <td class="p-2">{reservation.party_size}</td>
                <td class="p-2">{reservation.datetime}</td>
                <td class="p-2">
                  <span class={"px-2 py-1 rounded text-sm capitalize #{status_color(reservation.status)}"}>
                    {reservation.status}
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

  defp status_color(:confirmed), do: "bg-green-100 text-green-800"
  defp status_color(:cancelled), do: "bg-red-100 text-red-800"
  defp status_color(:completed), do: "bg-blue-100 text-blue-800"
  defp status_color(:no_show), do: "bg-gray-100 text-gray-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"
end
