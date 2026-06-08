defmodule Orderflow.GiftCardsFixtures do
  @moduledoc """
  This module defines test helpers for creating gift cards.
  """

  alias Orderflow.GiftCards

  def gift_card_fixture(attrs \\ %{}) do
    {:ok, gift_card} =
      GiftCards.create_gift_card(
        Enum.into(attrs, %{
          initial_amount: "50.00",
          balance: "50.00",
          recipient_email: "recipient@example.com",
          message: "Happy Birthday!"
        })
      )

    gift_card
  end
end
