defmodule OrderflowWebhooks do
  @moduledoc """
  Contexto de webhooks para integraciones externas.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias OrderflowWebhooks.Webhook

  def list_webhooks do
    Repo.all(Webhook)
  end

  def create_webhook(attrs \\ %{}) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end

  def trigger_webhooks(event, payload) do
    webhooks =
      Webhook
      |> where([w], ^event in w.events and w.active == true)
      |> Repo.all()

    Enum.each(webhooks, fn webhook ->
      %{"url" => webhook.url, "event" => event, "payload" => payload}
      |> Orderflow.Workers.WebhookDelivery.new()
      |> Oban.insert()
    end)
  end
end
