defmodule Orderflow.Workers.BulkNotification do
  @moduledoc """
  Oban worker for bulk notifications.
  """
  use Oban.Worker, queue: :notifications, max_attempts: 2

  @impl Oban.Worker
  def perform(%{args: %{"user_id" => user_id, "message" => message, "channel" => channel}}) do
    IO.puts("[Bulk #{channel}] User #{user_id}: #{message}")
    :ok
  end
end
