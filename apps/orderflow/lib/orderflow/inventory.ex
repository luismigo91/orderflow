defmodule Orderflow.Inventory do
  @moduledoc """
  Context for inventory management and low stock alerts.
  """
  import Ecto.Query

  alias Orderflow.Catalog.Product
  alias Orderflow.Inventory.Alert
  alias Orderflow.Repo

  @low_stock_threshold 5

  @doc """
  Check all products and create alerts for low stock items.
  """
  def check_stock_levels do
    low_stock_products =
      Product
      |> where([p], p.stock <= @low_stock_threshold and p.active == true)
      |> Repo.all()

    Enum.each(low_stock_products, fn product ->
      create_alert(product)
    end)

    low_stock_products
  end

  @doc """
  Get all unresolved alerts.
  """
  def list_unresolved_alerts do
    Alert
    |> where([a], a.resolved == false)
    |> preload(:product)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Resolve an alert (e.g., after restocking).
  """
  def resolve_alert(alert_id) do
    Alert
    |> Repo.get!(alert_id)
    |> Alert.changeset(%{resolved: true})
    |> Repo.update()
  end

  defp create_alert(product) do
    # Check if alert already exists and is unresolved
    existing =
      Alert
      |> where([a], a.product_id == ^product.id and a.resolved == false)
      |> Repo.one()

    if is_nil(existing) do
      %Alert{}
      |> Alert.changeset(%{
        product_id: product.id,
        threshold: @low_stock_threshold,
        current_stock: product.stock,
        resolved: false
      })
      |> Repo.insert()
    end
  end
end
