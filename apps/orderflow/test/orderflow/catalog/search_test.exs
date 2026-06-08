defmodule Orderflow.Catalog.SearchTest do
  use Orderflow.DataCase

  alias Orderflow.Catalog
  alias Orderflow.Catalog.Search

  describe "search" do
    setup do
      {:ok, category} = Catalog.create_category(%{name: "Food", description: "Food items"})

      {:ok, pizza} =
        Catalog.create_product(%{
          name: "Pizza Margherita",
          description: "Classic Italian pizza with tomato and mozzarella",
          price: "12.00",
          stock: 10,
          category_id: category.id
        })

      {:ok, pasta} =
        Catalog.create_product(%{
          name: "Pasta Carbonara",
          description: "Creamy pasta with bacon and eggs",
          price: "15.00",
          stock: 8,
          category_id: category.id
        })

      %{pizza: pizza, pasta: pasta}
    end

    test "search_products finds by name", %{pizza: pizza} do
      results = Search.search_products("pizza")
      assert length(results) >= 1
      assert Enum.any?(results, &(&1.id == pizza.id))
    end

    test "search_products finds by description", %{pasta: pasta} do
      results = Search.search_products("carbonara")
      assert length(results) >= 1
      assert Enum.any?(results, &(&1.id == pasta.id))
    end

    test "search_products returns empty for no match" do
      results = Search.search_products("nonexistent")
      assert results == []
    end

    test "search_products handles empty query" do
      assert Search.search_products("") == []
      assert Search.search_products(nil) == []
    end
  end
end
