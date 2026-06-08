defmodule OrderflowWeb.Api.ExportController do
  use OrderflowWeb, :controller

  alias Orderflow.Exports

  def export_orders(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    {:ok, start_dt} = NaiveDateTime.from_iso8601(start_date <> " 00:00:00")
    {:ok, end_dt} = NaiveDateTime.from_iso8601(end_date <> " 23:59:59")

    csv = Exports.export_orders_by_date_range(start_dt, end_dt)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=orders.csv")
    |> send_resp(200, csv)
  end

  def export_receipt(conn, %{"id" => id}) do
    order = Orderflow.Orders.get_order_with_items!(id)
    html = Exports.generate_receipt_html(order)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
end
