defmodule Orderflow.LoyaltyFixtures do
  @moduledoc """
  This module defines test helpers for creating loyalty tiers.
  """

  alias Orderflow.Loyalty

  def tier_fixture(attrs \\ %{}) do
    {:ok, tier} =
      Loyalty.create_tier(
        Enum.into(attrs, %{
          name: "Tier #{System.unique_integer([:positive])}",
          min_points: 100,
          multiplier: "1.5",
          benefits: ["Free delivery", "10% discount"],
          active: true
        })
      )

    tier
  end

  def user_loyalty_fixture(user_id, attrs \\ %{}) do
    {:ok, loyalty} =
      Loyalty.create_user_loyalty(
        Enum.into(attrs, %{
          user_id: user_id,
          total_points: 0,
          available_points: 0,
          lifetime_points: 0
        })
      )

    loyalty
  end
end
