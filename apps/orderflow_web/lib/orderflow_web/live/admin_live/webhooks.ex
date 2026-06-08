defmodule OrderflowWeb.AdminLive.Webhooks do
  use OrderflowWeb, :live_view

  alias OrderflowWebhooks

  @impl true
  def mount(_params, _session, socket) do
    webhooks = OrderflowWebhooks.list_webhooks()

    {:ok,
     socket
     |> assign(:webhooks, webhooks)
     |> assign(:page_title, "Webhooks")}
  end
end
