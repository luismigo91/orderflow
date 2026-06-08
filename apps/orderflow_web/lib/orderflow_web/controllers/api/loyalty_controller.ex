defmodule OrderflowWeb.Api.LoyaltyController do
  use OrderflowWeb, :controller

  alias Orderflow.Loyalty

  def tiers(conn, _params) do
    tiers = Loyalty.list_tiers()
    render(conn, :tiers, tiers: tiers)
  end

  def me(conn, _params) do
    user = conn.assigns.current_user
    loyalty = Loyalty.get_user_loyalty(user.id)
    render(conn, :me, loyalty: loyalty)
  end
end

defmodule OrderflowWeb.Api.LoyaltyJSON do
  def tiers(%{tiers: tiers}) do
    %{data: for(tier <- tiers, do: tier_data(tier))}
  end

  def me(%{loyalty: nil}) do
    %{data: nil}
  end

  def me(%{loyalty: loyalty}) do
    tier = loyalty.current_tier

    %{
      data: %{
        total_points: loyalty.total_points,
        available_points: loyalty.available_points,
        lifetime_points: loyalty.lifetime_points,
        current_tier: tier && tier_data(tier)
      }
    }
  end

  defp tier_data(tier) do
    %{
      id: tier.id,
      name: tier.name,
      min_points: tier.min_points,
      multiplier: tier.multiplier,
      benefits: tier.benefits,
      icon: tier.icon
    }
  end
end
