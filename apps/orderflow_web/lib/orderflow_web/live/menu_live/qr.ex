defmodule OrderflowWeb.MenuLive.Qr do
  use OrderflowWeb, :live_view

  alias Orderflow.QrMenus
  alias Orderflow.Catalog

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    qr_menu = QrMenus.get_qr_menu_by_code(code)

    if qr_menu do
      QrMenus.increment_scan(qr_menu)
      products = Catalog.list_active_products()
      {:ok, assign(socket, qr_menu: qr_menu, products: products, page_title: "Digital Menu")}
    else
      {:ok, assign(socket, qr_menu: nil, products: [], page_title: "Menu Not Found")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-4xl mx-auto">
      <%= if @qr_menu do %>
        <div class="text-center mb-6">
          <h1 class="text-3xl font-bold mb-2">Digital Menu</h1>
          <p class="text-gray-600">Table: {@qr_menu.table && @qr_menu.table.number}</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <%= for product <- @products do %>
            <div class="p-4 border rounded-lg">
              <div class="flex justify-between items-start">
                <div>
                  <h3 class="font-bold text-lg">{product.name}</h3>
                  <p class="text-sm text-gray-600 mb-2">{product.description}</p>
                  <div class="text-xl font-bold text-green-600">${product.price}</div>
                </div>
              </div>
              <%= if product.allergens != [] do %>
                <div class="mt-2 text-xs text-red-600">
                  <strong>Allergens:</strong> {Enum.join(product.allergens, ", ")}
                </div>
              <% end %>
              <%= if product.nutritional_info != %{} do %>
                <div class="mt-1 text-xs text-gray-500">
                  <%= for {key, value} <- product.nutritional_info do %>
                    <span class="mr-2">{key}: {value}</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="text-center py-12">
          <h1 class="text-2xl font-bold text-red-600 mb-4">Menu Not Found</h1>
          <p class="text-gray-600">This QR code is invalid or has expired.</p>
        </div>
      <% end %>
    </div>
    """
  end
end
