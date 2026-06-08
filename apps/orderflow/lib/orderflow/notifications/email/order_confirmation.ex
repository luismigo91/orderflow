defmodule Orderflow.Notifications.Email.OrderConfirmation do
  @moduledoc """
  Email template for order confirmations.
  """
  import Swoosh.Email

  def new(attrs) do
    new()
    |> to("customer@example.com")
    |> from("noreply@orderflow.com")
    |> subject("Order ##{attrs.order_id} Confirmation")
    |> text_body("""
    Order Confirmation

    Order ##{attrs.order_id}
    Customer: #{attrs.customer_name}
    Status: #{attrs.status}
    Total: $#{attrs.total}

    Thank you for your order!
    """)
  end
end
