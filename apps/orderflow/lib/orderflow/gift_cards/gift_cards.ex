defmodule Orderflow.GiftCards do
  @moduledoc """
  Context for gift card management.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.GiftCards.GiftCard

  def list_gift_cards do
    GiftCard |> preload(:purchaser) |> order_by([g], desc: g.inserted_at) |> Repo.all()
  end

  def get_gift_card!(id), do: Repo.get!(GiftCard, id) |> Repo.preload(:purchaser)

  def get_gift_card_by_code(code) do
    GiftCard
    |> where([g], g.code == ^code)
    |> preload(:purchaser)
    |> Repo.one()
  end

  def create_gift_card(attrs) do
    code = generate_code()
    amount = Map.get(attrs, "initial_amount") || Map.get(attrs, :initial_amount)

    %GiftCard{}
    |> GiftCard.changeset(%{
      code: code,
      balance: amount,
      initial_amount: amount,
      purchaser_id: Map.get(attrs, "purchaser_id") || Map.get(attrs, :purchaser_id),
      recipient_email: Map.get(attrs, "recipient_email") || Map.get(attrs, :recipient_email),
      message: Map.get(attrs, "message") || Map.get(attrs, :message),
      status: :active,
      expires_at: DateTime.add(DateTime.utc_now(), 365, :day)
    })
    |> Repo.insert()
  end

  def redeem_gift_card(code, amount) do
    gift_card = get_gift_card_by_code(code)

    cond do
      is_nil(gift_card) ->
        {:error, :not_found}

      gift_card.status != :active ->
        {:error, :not_active}

      gift_card.expires_at && DateTime.compare(gift_card.expires_at, DateTime.utc_now()) == :lt ->
        {:error, :expired}

      Decimal.compare(gift_card.balance, amount) == :lt ->
        {:error, :insufficient_balance}

      true ->
        new_balance = Decimal.sub(gift_card.balance, amount)

        new_status =
          if Decimal.compare(new_balance, Decimal.new(0)) == :eq, do: :redeemed, else: :active

        gift_card
        |> GiftCard.changeset(%{
          balance: new_balance,
          status: new_status,
          redeemed_at:
            if(new_status == :redeemed, do: DateTime.utc_now(), else: gift_card.redeemed_at)
        })
        |> Repo.update()
    end
  end

  defp generate_code do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64(padding: false)
    |> String.replace(~r/[^A-Za-z0-9]/, "")
    |> String.slice(0, 12)
    |> String.upcase()
  end
end
