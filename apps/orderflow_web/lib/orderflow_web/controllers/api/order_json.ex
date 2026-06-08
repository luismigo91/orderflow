defmodule OrderflowWeb.Api.OrderJSON do
  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: data(order))}
  end

  def show(%{order: order}) do
    %{data: data(order)}
  end

  defp data(order) do
    %{
      id: order.id,
      customer_name: order.customer_name,
      customer_phone: order.customer_phone,
      status: order.status,
      total: order.total,
      notes: order.notes,
      items: for(item <- order.order_items, do: item_data(item)),
      inserted_at: order.inserted_at,
      updated_at: order.updated_at
    }
  end

  defp item_data(item) do
    %{
      product_id: item.product_id,
      name: item.product.name,
      quantity: item.quantity,
      unit_price: item.unit_price,
      subtotal: item.subtotal
    }
  end
end
