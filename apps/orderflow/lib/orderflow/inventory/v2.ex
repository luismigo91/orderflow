defmodule Orderflow.Inventory.V2 do
  @moduledoc """
  Advanced inventory management with stock movements.
  """
  import Ecto.Query

  alias Orderflow.Catalog.Product
  alias Orderflow.Inventory.StockMovement
  alias Orderflow.Repo

  @doc """
  Record stock movement.
  """
  def record_movement(product_id, quantity, type, reason \\ nil) do
    %StockMovement{}
    |> StockMovement.changeset(%{
      product_id: product_id,
      quantity: quantity,
      type: type,
      reason: reason
    })
    |> Repo.insert()
  end

  @doc """
  Get stock movements for a product.
  """
  def list_movements(product_id) do
    StockMovement
    |> where([m], m.product_id == ^product_id)
    |> order_by(desc: :inserted_at)
    |> preload(:product)
    |> Repo.all()
  end

  @doc """
  Adjust stock (with movement tracking).
  """
  def adjust_stock(product_id, quantity, reason) do
    product = Repo.get!(Product, product_id)
    new_stock = product.stock + quantity

    Repo.transaction(fn ->
      # Update product
      product
      |> Ecto.Changeset.change(stock: new_stock)
      |> Repo.update!()

      # Record movement
      {:ok, _} = record_movement(product_id, quantity, :adjustment, reason)
    end)
  end

  @doc """
  Get current stock value for all products.
  """
  def inventory_value do
    Product
    |> where([p], is_nil(p.deleted_at))
    |> select([p], sum(p.stock * p.price))
    |> Repo.one()
    |> case do
      nil -> Decimal.new("0.00")
      value -> value
    end
  end

  @doc """
  Get low stock report.
  """
  def low_stock_report(threshold \\ 5) do
    Product
    |> where([p], p.stock <= ^threshold)
    |> where([p], is_nil(p.deleted_at))
    |> where([p], p.active == true)
    |> preload(:category)
    |> Repo.all()
  end
end
