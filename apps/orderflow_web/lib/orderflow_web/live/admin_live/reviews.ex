defmodule OrderflowWeb.AdminLive.Reviews do
  use OrderflowWeb, :live_view

  alias Orderflow.Reviews

  @impl true
  def mount(_params, _session, socket) do
    reviews = Reviews.list_reviews()

    {:ok,
     socket
     |> assign(:reviews, reviews)
     |> assign(:page_title, "Reviews")}
  end
end
