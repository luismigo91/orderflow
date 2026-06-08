defmodule Orderflow.Workers.SMSNotification do
  @moduledoc """
  Oban worker for SMS notifications.
  """
  use Oban.Worker, queue: :notifications, max_attempts: 3

  @impl Oban.Worker
  def perform(%{args: %{"order_id" => order_id, "phone" => phone}}) do
    # Simulate SMS
    IO.puts("[SMS] Order #{order_id} to #{phone}: Status updated")
    :ok
  end
end
