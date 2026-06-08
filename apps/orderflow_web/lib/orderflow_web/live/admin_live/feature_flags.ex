defmodule OrderflowWeb.AdminLive.FeatureFlags do
  use OrderflowWeb, :live_view

  alias Orderflow.FeatureFlags

  @impl true
  def mount(_params, _session, socket) do
    flags = FeatureFlags.list_feature_flags()

    {:ok,
     socket
     |> assign(:flags, flags)
     |> assign(:page_title, "Feature Flags")}
  end

  @impl true
  def handle_event("toggle", %{"name" => name}, socket) do
    FeatureFlags.toggle(name)
    flags = FeatureFlags.list_feature_flags()
    {:noreply, assign(socket, :flags, flags)}
  end
end
