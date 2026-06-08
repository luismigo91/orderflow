defmodule Orderflow.Workers.WebhookDelivery do
  @moduledoc """
  Oban worker for delivering webhooks.
  """
  use Oban.Worker, queue: :webhooks, max_attempts: 5

  alias Req

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url, "event" => event, "payload" => payload}}) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Webhook-Event", event}
    ]

    case Req.post(url, json: payload, headers: headers, max_retries: 3) do
      {:ok, %{status: status}} when status in 200..299 ->
        :ok

      {:ok, %{status: status}} ->
        {:error, "Webhook returned status #{status}"}

      {:error, reason} ->
        {:error, "Webhook delivery failed: #{inspect(reason)}"}
    end
  end
end
