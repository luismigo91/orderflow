defmodule Orderflow.Notifications.Advanced do
  @moduledoc """
  Advanced notifications with SMS, Email, and Push.
  Uses Oban for background delivery.
  """
  alias Orderflow.Notifications.Email

  @doc """
  Send order notification via multiple channels.
  """
  def send_order_notification(order, channels \\ [:email, :push]) do
    Enum.each(channels, fn channel ->
      case channel do
        :email -> send_email_notification(order)
        :push -> send_push_notification(order)
        :sms -> send_sms_notification(order)
        _ -> :ok
      end
    end)
  end

  defp send_email_notification(order) do
    %{
      order_id: order.id,
      customer_name: order.customer_name,
      status: order.status,
      total: order.total
    }
    |> Email.OrderConfirmation.new()
    |> Orderflow.Mailer.deliver()
  end

  defp send_push_notification(order) do
    # Queue push notification via Oban
    %{order_id: order.id, event: "order_#{order.status}"}
    |> Orderflow.Workers.PushNotification.new()
    |> Oban.insert()
  end

  defp send_sms_notification(order) do
    # Queue SMS via Oban
    %{order_id: order.id, phone: order.customer_phone}
    |> Orderflow.Workers.SMSNotification.new()
    |> Oban.insert()
  end

  @doc """
  Send bulk notification to all users.
  """
  def send_bulk_notification(user_ids, message, channel \\ :email) do
    Enum.each(user_ids, fn user_id ->
      %{user_id: user_id, message: message, channel: channel}
      |> Orderflow.Workers.BulkNotification.new()
      |> Oban.insert()
    end)
  end
end
