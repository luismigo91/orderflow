defmodule OrderflowWeb.Api.BulkController do
  use OrderflowWeb, :controller

  alias Orderflow.BulkOperations

  def bulk_update_products(conn, %{"ids" => ids, "active" => active}) do
    {count, _} = BulkOperations.bulk_update_product_status(ids, active)

    json(conn, %{
      success: true,
      updated: count,
      message: "#{count} products updated"
    })
  end

  def bulk_archive_orders(conn, %{"ids" => ids}) do
    {count, _} = BulkOperations.bulk_archive_orders(ids)

    json(conn, %{
      success: true,
      archived: count,
      message: "#{count} orders archived"
    })
  end
end
