defmodule OrderflowWeb.Api.SearchController do
  use OrderflowWeb, :controller

  alias Orderflow.Catalog.Search

  def search_products(conn, %{"q" => query}) do
    products = Search.search_products(query)

    render(conn, :products, products: products)
  end

  def search_products(conn, _) do
    json(conn, %{products: []})
  end
end
