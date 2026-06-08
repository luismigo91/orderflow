defmodule OrderflowWeb.AdminLive.Tables do
  use OrderflowWeb, :live_view

  alias Orderflow.Tables

  @impl true
  def mount(_params, _session, socket) do
    tables = Tables.list_tables()
    {:ok, assign(socket, tables: tables, page_title: "Table Management")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Table Management</h1>
      <div class="grid grid-cols-4 gap-4">
        <%= for table <- @tables do %>
          <div class={"p-4 rounded-lg border-2 #{table_status_color(table.status)}"}>
            <div class="text-lg font-bold">Table {table.number}</div>
            <div class="text-sm">Capacity: {table.capacity}</div>
            <div class="text-sm capitalize">{table.status}</div>
            <div class="text-sm text-gray-500">{table.location}</div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp table_status_color(:free), do: "border-green-500 bg-green-50"
  defp table_status_color(:occupied), do: "border-red-500 bg-red-50"
  defp table_status_color(:reserved), do: "border-yellow-500 bg-yellow-50"
  defp table_status_color(_), do: "border-gray-500 bg-gray-50"
end
