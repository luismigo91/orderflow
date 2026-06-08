defmodule Orderflow.CatalogTest do
  use Orderflow.DataCase

  alias Orderflow.Catalog
  alias Orderflow.Catalog.Category
  alias Orderflow.Catalog.Product

  describe "categories" do
    @valid_attrs %{name: "Bebidas", description: "Refrescos", sort_order: 1}
    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories ordered by sort_order and name" do
      category = category_fixture()
      assert Catalog.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Catalog.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Catalog.create_category(@valid_attrs)
      assert category.name == "Bebidas"
      assert category.description == "Refrescos"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Catalog.update_category(category, %{name: "Updated"})
      assert category.name == "Updated"
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "products" do
    @valid_attrs %{
      name: "Pizza",
      description: "Deliciosa",
      price: "12.00",
      stock: 10,
      active: true
    }
    @invalid_attrs %{name: nil, price: nil, category_id: nil}

    test "list_products/0 returns all products with categories" do
      product = product_fixture()
      assert [listed_product] = Catalog.list_products()
      assert listed_product.id == product.id
      assert listed_product.category != nil
    end

    test "list_products_by_category/1 returns products for a category" do
      product = product_fixture()
      assert [listed_product] = Catalog.list_products_by_category(product.category_id)
      assert listed_product.id == product.id
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      found = Catalog.get_product!(product.id)
      assert found.id == product.id
      assert found.name == product.name
      assert found.category != nil
    end

    test "create_product/1 with valid data creates a product" do
      category = category_fixture()
      attrs = Map.put(@valid_attrs, :category_id, category.id)
      assert {:ok, %Product{} = product} = Catalog.create_product(attrs)
      assert product.name == "Pizza"
      assert product.price == Decimal.new("12.00")
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "create_product/1 with negative price returns error" do
      category = category_fixture()
      attrs = %{name: "Pizza", price: "-5.00", category_id: category.id}
      assert {:error, changeset} = Catalog.create_product(attrs)
      assert "debe ser mayor que 0" in errors_on(changeset).price
    end

    test "create_product/1 with negative stock returns error" do
      category = category_fixture()
      attrs = %{name: "Pizza", price: "12.00", stock: -1, category_id: category.id}
      assert {:error, changeset} = Catalog.create_product(attrs)
      assert "no puede ser negativo" in errors_on(changeset).stock
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      assert {:ok, %Product{} = product} =
               Catalog.update_product(product, %{name: "Updated Pizza"})

      assert product.name == "Updated Pizza"
    end

    test "delete_product/1 soft deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{deleted_at: deleted_at}} = Catalog.delete_product(product)
      assert deleted_at != nil
      # Soft deleted product should not appear in list_products
      assert Catalog.list_products() |> Enum.find(&(&1.id == product.id)) == nil
      # But should be in list_deleted_products
      assert Catalog.list_deleted_products() |> Enum.find(&(&1.id == product.id)) != nil
      # And can be restored
      assert {:ok, %Product{deleted_at: nil}} = Catalog.restore_product(product)
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end

    test "decrement_stock/2 reduces stock" do
      product = product_fixture(stock: 10)
      assert {:ok, %Product{} = product} = Catalog.decrement_stock(product, 3)
      assert product.stock == 7
    end

    test "decrement_stock/2 fails when insufficient stock" do
      product = product_fixture(stock: 2)
      assert {:error, :insufficient_stock} = Catalog.decrement_stock(product, 5)
    end

    test "restore_stock/2 increases stock" do
      product = product_fixture(stock: 5)
      assert {:ok, %Product{} = product} = Catalog.restore_stock(product, 3)
      assert product.stock == 8
    end
  end

  defp category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{name: "Test Category", description: "Test", sort_order: 1})
      |> Catalog.create_category()

    category
  end

  defp product_fixture(attrs \\ %{}) do
    category = category_fixture()

    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "Test Product",
        description: "Test",
        price: "10.00",
        stock: 10,
        active: true,
        category_id: category.id
      })
      |> Catalog.create_product()

    product
  end
end
