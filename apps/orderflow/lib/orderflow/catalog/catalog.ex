defmodule Orderflow.Catalog do
  @moduledoc """
  Contexto de gestión de catálogo: categorías y productos.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Catalog.Category
  alias Orderflow.Catalog.Product

  # Categories

  def list_categories do
    Category
    |> order_by([c], asc: c.sort_order, asc: c.name)
    |> Repo.all()
  end

  def get_category!(id), do: Repo.get!(Category, id)
  def get_category(id), do: Repo.get(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    category
    |> Repo.delete()
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  # Products

  def list_products do
    Product
    |> where([p], is_nil(p.deleted_at))
    |> preload(:category)
    |> order_by([p], p.name)
    |> Repo.all()
  end

  def list_deleted_products do
    Product
    |> where([p], not is_nil(p.deleted_at))
    |> preload(:category)
    |> order_by([p], p.name)
    |> Repo.all()
  end

  def list_products_by_category(category_id) do
    Product
    |> where([p], p.category_id == ^category_id)
    |> preload(:category)
    |> order_by([p], p.name)
    |> Repo.all()
  end

  def list_active_products do
    Product
    |> where([p], p.active == true and is_nil(p.deleted_at))
    |> preload(:category)
    |> order_by([p], p.name)
    |> Repo.all()
  end

  def get_product!(id) do
    Product
    |> preload(:category)
    |> Repo.get!(id)
  end

  def get_product(id) do
    Product
    |> preload(:category)
    |> Repo.get(id)
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    product
    |> Ecto.Changeset.change(
      deleted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    )
    |> Repo.update()
  end

  def restore_product(%Product{} = product) do
    product
    |> Ecto.Changeset.change(deleted_at: nil)
    |> Repo.update()
  end

  def permanently_delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def decrement_stock(%Product{} = product, amount) do
    if product.stock >= amount do
      product
      |> Ecto.Changeset.change(stock: product.stock - amount)
      |> Repo.update()
    else
      {:error, :insufficient_stock}
    end
  end

  def restore_stock(%Product{} = product, amount) do
    product
    |> Ecto.Changeset.change(stock: product.stock + amount)
    |> Repo.update()
  end
end
