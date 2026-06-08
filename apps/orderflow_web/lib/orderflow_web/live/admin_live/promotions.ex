defmodule OrderflowWeb.AdminLive.Promotions do
  use OrderflowWeb, :live_view

  alias Orderflow.Promotions

  @impl true
  def mount(_params, _session, socket) do
    promotions = Promotions.list_promotions()

    {:ok,
     socket
     |> assign(:promotions, promotions)
     |> assign(:page_title, "Promociones")}
  end
end
