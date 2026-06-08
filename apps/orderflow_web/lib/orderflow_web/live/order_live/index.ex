defmodule OrderflowWeb.OrderLive.Index do
  use OrderflowWeb, :live_view

  alias Orderflow.Orders
  alias Orderflow.Catalog

  @impl true
  def mount(_params, _session, socket) do
    products = Catalog.list_products()

    {:ok,
     socket
     |> assign(:products, products)
     |> assign(:page_title, "Nuevo Pedido")}
  end

  @impl true
  def handle_event("create_order", %{"order" => order_params, "items" => items}, socket) do
    user = socket.assigns.current_user

    items =
      Enum.map(items, fn item ->
        %{
          "product_id" => item["product_id"],
          "quantity" => String.to_integer(item["quantity"]),
          "notes" => item["notes"]
        }
      end)

    attrs = Map.put(order_params, "items", items)

    case Orders.create_order(attrs, user.id) do
      {:ok, order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pedido #{order.id} creado exitosamente.")
         |> redirect(to: ~p"/track/#{order.id}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al crear el pedido.")}
    end
  end
end
