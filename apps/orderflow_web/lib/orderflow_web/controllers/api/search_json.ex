defmodule OrderflowWeb.Api.SearchJSON do
  def products(%{products: products}) do
    %{products: Enum.map(products, &product_json/1)}
  end

  defp product_json(product) do
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      active: product.active
    }
  end
end
