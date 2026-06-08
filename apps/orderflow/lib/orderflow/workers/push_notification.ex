defmodule Orderflow.Workers.PushNotification do
  @moduledoc """
  Oban worker for push notifications.
  """
  use Oban.Worker, queue: :notifications, max_attempts: 3

  @impl Oban.Worker
  def perform(%{args: %{"order_id" => order_id, "event" => event}}) do
    # Simulate push notification
    IO.puts("[Push] Order #{order_id}: #{event}")
    :ok
  end
end
