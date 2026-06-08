defmodule Orderflow.GiftCardsTest do
  use Orderflow.DataCase

  alias Orderflow.GiftCards
  alias Orderflow.GiftCardsFixtures

  describe "gift cards" do
    test "create_gift_card/1 creates a gift card with unique code" do
      assert {:ok, gift_card} = GiftCards.create_gift_card(%{initial_amount: "100.00"})
      assert gift_card.balance == Decimal.new("100.00")
      assert gift_card.status == :active
      assert String.length(gift_card.code) > 0
    end

    test "redeem_gift_card/2 with valid amount" do
      gift_card = GiftCardsFixtures.gift_card_fixture(%{initial_amount: "50.00"})
      assert {:ok, updated} = GiftCards.redeem_gift_card(gift_card.code, "20.00")
      assert updated.balance == Decimal.new("30.00")
    end

    test "redeem_gift_card/2 with insufficient balance" do
      gift_card = GiftCardsFixtures.gift_card_fixture(%{initial_amount: "10.00"})
      assert {:error, :insufficient_balance} = GiftCards.redeem_gift_card(gift_card.code, "20.00")
    end

    test "redeem_gift_card/2 with invalid code" do
      assert {:error, :not_found} = GiftCards.redeem_gift_card("INVALID", "10.00")
    end
  end
end
