defmodule OrderflowWeb.Api.ProductJSON do
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(product) do
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      active: product.active,
      category: %{
        id: product.category.id,
        name: product.category.name
      }
    }
  end
end
