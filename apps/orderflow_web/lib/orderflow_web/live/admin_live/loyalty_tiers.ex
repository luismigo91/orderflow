defmodule OrderflowWeb.AdminLive.LoyaltyTiers do
  use OrderflowWeb, :live_view

  alias Orderflow.Loyalty

  @impl true
  def mount(_params, _session, socket) do
    tiers = Loyalty.list_tiers()
    {:ok, assign(socket, tiers: tiers, page_title: "Loyalty Tiers")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Loyalty Tiers</h1>
      <div class="grid grid-cols-3 gap-4">
        <%= for tier <- @tiers do %>
          <div class="p-4 border rounded-lg shadow-sm">
            <div class="text-xl font-bold mb-2">{tier.name}</div>
            <div class="text-sm text-gray-600 mb-2">Min: {tier.min_points} points</div>
            <div class="text-sm text-gray-600 mb-2">Multiplier: {tier.multiplier}x</div>
            <div class="text-sm">
              <strong>Benefits:</strong>
              <ul class="list-disc list-inside">
                <%= for benefit <- tier.benefits do %>
                  <li>{benefit}</li>
                <% end %>
              </ul>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
