defmodule OrderflowWeb.AdminLive.OrderHistory do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders

  @impl true
  def mount(_params, _session, socket) do
    orders = Orders.list_orders()

    {:ok,
     socket
     |> assign(:orders, orders)
     |> assign(:page_title, "Historial de Pedidos")}
  end

  @impl true
  def handle_event("export_csv", _params, socket) do
    csv = generate_csv(socket.assigns.orders)

    {:noreply,
     socket
     |> push_event("download_csv", %{filename: "orders.csv", content: csv})}
  end

  defp generate_csv(orders) do
    headers = "ID,Cliente,Teléfono,Estado,Total,Notas,Fecha\n"

    rows =
      Enum.map(orders, fn order ->
        "#{order.id},\"#{order.customer_name}\",\"#{order.customer_phone}\",#{order.status},#{order.total},\"#{order.notes || ""}\",#{order.inserted_at}\n"
      end)
      |> Enum.join()

    headers <> rows
  end
end
