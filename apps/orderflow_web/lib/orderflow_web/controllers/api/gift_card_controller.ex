defmodule OrderflowWeb.Api.GiftCardController do
  use OrderflowWeb, :controller

  alias Orderflow.GiftCards
  alias Orderflow.GiftCards.GiftCard

  def index(conn, _params) do
    gift_cards = GiftCards.list_gift_cards()
    render(conn, :index, gift_cards: gift_cards)
  end

  def create(conn, %{"gift_card" => gift_card_params}) do
    with {:ok, %GiftCard{} = gift_card} <- GiftCards.create_gift_card(gift_card_params) do
      conn
      |> put_status(:created)
      |> render(:show, gift_card: gift_card)
    end
  end

  def show(conn, %{"id" => id}) do
    gift_card = GiftCards.get_gift_card!(id)
    render(conn, :show, gift_card: gift_card)
  end

  def redeem(conn, %{"code" => code, "amount" => amount}) do
    with {:ok, %GiftCard{} = gift_card} <- GiftCards.redeem_gift_card(code, amount) do
      render(conn, :show, gift_card: gift_card)
    end
  end
end

defmodule OrderflowWeb.Api.GiftCardJSON do
  alias Orderflow.GiftCards.GiftCard

  def index(%{gift_cards: gift_cards}) do
    %{data: for(card <- gift_cards, do: data(card))}
  end

  def show(%{gift_card: gift_card}) do
    %{data: data(gift_card)}
  end

  defp data(%GiftCard{} = gift_card) do
    %{
      id: gift_card.id,
      code: gift_card.code,
      balance: gift_card.balance,
      initial_amount: gift_card.initial_amount,
      status: gift_card.status,
      recipient_email: gift_card.recipient_email,
      expires_at: gift_card.expires_at,
      redeemed_at: gift_card.redeemed_at,
      inserted_at: gift_card.inserted_at
    }
  end
end
