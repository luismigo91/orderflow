defmodule OrderflowWeb.AdminLive.ProductManagement do
  use OrderflowWeb, :live_view

  alias Orderflow.Catalog

  @impl true
  def mount(_params, _session, socket) do
    products = Catalog.list_products()

    {:ok,
     socket
     |> assign(:products, products)
     |> assign(:page_title, "Gestión de Productos")}
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, updated_product} = Catalog.update_product(product, %{active: !product.active})

    products =
      Enum.map(socket.assigns.products, fn p ->
        if p.id == updated_product.id, do: updated_product, else: p
      end)

    {:noreply, assign(socket, :products, products)}
  end
end
