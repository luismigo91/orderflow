defmodule Orderflow.Exports do
  @moduledoc """
  Context for exporting data in various formats.
  """
  alias Orderflow.Orders
  alias Orderflow.Orders.Order

  @doc """
  Export orders to CSV format.
  """
  def export_orders_csv(orders) do
    headers = ["ID", "Customer", "Phone", "Total", "Status", "Items", "Created At"]

    rows =
      Enum.map(orders, fn order ->
        items =
          Enum.map(order.order_items, fn item ->
            "#{item.product.name} x#{item.quantity}"
          end)
          |> Enum.join("; ")

        [
          to_string(order.id),
          order.customer_name,
          order.customer_phone || "",
          Decimal.to_string(order.total),
          Atom.to_string(order.status),
          items,
          NaiveDateTime.to_string(order.inserted_at)
        ]
      end)

    Orderflow.Exports.CSVHelper.encode_to_string([headers | rows])
  end

  @doc """
  Generate a simple HTML receipt for an order.
  """
  def generate_receipt_html(%Order{} = order) do
    items_html =
      Enum.map(order.order_items, fn item ->
        """
        <tr>
          <td>#{item.product.name}</td>
          <td>#{item.quantity}</td>
          <td>$#{item.unit_price}</td>
          <td>$#{item.subtotal}</td>
        </tr>
        """
      end)
      |> Enum.join("\n")

    """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Receipt ##{order.id}</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }
        h1 { text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
        .total { font-size: 1.2em; font-weight: bold; text-align: right; margin-top: 20px; }
      </style>
    </head>
    <body>
      <h1>OrderFlow Receipt</h1>
      <p><strong>Order #:</strong> #{order.id}</p>
      <p><strong>Customer:</strong> #{order.customer_name}</p>
      <p><strong>Date:</strong> #{order.inserted_at}</p>
      <p><strong>Status:</strong> #{String.upcase(Atom.to_string(order.status))}</p>
      
      <table>
        <thead>
          <tr>
            <th>Item</th>
            <th>Qty</th>
            <th>Price</th>
            <th>Subtotal</th>
          </tr>
        </thead>
        <tbody>
          #{items_html}
        </tbody>
      </table>
      
      <p class="total">Total: $#{order.total}</p>
    </body>
    </html>
    """
  end

  @doc """
  Export a date range of orders.
  """
  def export_orders_by_date_range(start_date, end_date) do
    orders = Orders.list_orders_by_date_range(start_date, end_date)
    export_orders_csv(orders)
  end
end
