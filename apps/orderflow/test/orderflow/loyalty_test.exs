defmodule Orderflow.LoyaltyTest do
  use Orderflow.DataCase

  alias Orderflow.Loyalty
  alias Orderflow.LoyaltyFixtures
  alias Orderflow.AccountsFixtures

  describe "tiers" do
    test "list_tiers/0 returns active tiers" do
      tier = LoyaltyFixtures.tier_fixture()
      assert tier.id in Enum.map(Loyalty.list_tiers(), & &1.id)
    end

    test "create_tier/1 with valid data creates a tier" do
      assert {:ok, tier} =
               Loyalty.create_tier(%{
                 name: "Gold",
                 min_points: 1000,
                 multiplier: "2.0",
                 benefits: ["VIP support"]
               })

      assert tier.name == "Gold"
    end
  end

  describe "user loyalty" do
    test "add_user_points/2 adds points to user" do
      user = AccountsFixtures.user_fixture()
      assert {:ok, loyalty} = Loyalty.add_user_points(user.id, 100)
      assert loyalty.total_points == 100
      assert loyalty.available_points == 100
    end

    test "redeem_user_points/2 with sufficient points" do
      user = AccountsFixtures.user_fixture()
      {:ok, _} = Loyalty.add_user_points(user.id, 100)
      assert {:ok, loyalty} = Loyalty.redeem_user_points(user.id, 50)
      assert loyalty.available_points == 50
    end

    test "redeem_user_points/2 with insufficient points returns error" do
      user = AccountsFixtures.user_fixture()
      assert {:error, :insufficient_points} = Loyalty.redeem_user_points(user.id, 100)
    end
  end
end
