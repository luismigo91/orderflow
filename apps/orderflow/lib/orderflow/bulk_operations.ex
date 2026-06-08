defmodule Orderflow.BulkOperations do
  @moduledoc """
  Context for bulk operations on products and orders.
  """
  import Ecto.Query

  alias Orderflow.Catalog.Product
  alias Orderflow.Orders.Order
  alias Orderflow.Repo

  @doc """
  Bulk update product status (active/inactive).
  """
  def bulk_update_product_status(product_ids, active) when is_list(product_ids) do
    Product
    |> where([p], p.id in ^product_ids)
    |> Repo.update_all(set: [active: active, updated_at: NaiveDateTime.utc_now()])
  end

  @doc """
  Bulk update product stock.
  """
  def bulk_update_stock(product_ids, stock_delta) when is_list(product_ids) do
    Product
    |> where([p], p.id in ^product_ids)
    |> Repo.update_all(inc: [stock: stock_delta])
  end

  @doc """
  Bulk archive orders.
  """
  def bulk_archive_orders(order_ids) when is_list(order_ids) do
    Order
    |> where([o], o.id in ^order_ids)
    |> where([o], o.status in [:delivered, :cancelled])
    |> Repo.update_all(set: [archived: true, updated_at: NaiveDateTime.utc_now()])
  end

  @doc """
  Bulk delete products (soft delete by deactivating).
  """
  def bulk_delete_products(product_ids) when is_list(product_ids) do
    bulk_update_product_status(product_ids, false)
  end
end
