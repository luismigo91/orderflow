defmodule Orderflow.GiftCards.GiftCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gift_cards" do
    field :code, :string
    field :balance, :decimal
    field :initial_amount, :decimal
    field :recipient_email, :string
    field :status, Ecto.Enum, values: [:active, :redeemed, :expired, :cancelled], default: :active
    field :expires_at, :utc_datetime
    field :redeemed_at, :utc_datetime
    field :message, :string

    belongs_to :purchaser, Orderflow.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(gift_card, attrs) do
    gift_card
    |> cast(attrs, [
      :code,
      :balance,
      :initial_amount,
      :purchaser_id,
      :recipient_email,
      :status,
      :expires_at,
      :redeemed_at,
      :message
    ])
    |> validate_required([:code, :balance, :initial_amount])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> validate_number(:initial_amount, greater_than: 0)
    |> unique_constraint(:code)
    |> foreign_key_constraint(:purchaser_id)
  end
end
