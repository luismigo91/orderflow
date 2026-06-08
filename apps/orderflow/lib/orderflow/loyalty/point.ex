defmodule Orderflow.Loyalty.Point do
  @moduledoc """
  Schema for loyalty points transactions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "loyalty_points" do
    field :points, :integer
    field :type, Ecto.Enum, values: [:earned, :redeemed, :bonus, :expired]
    field :description, :string

    belongs_to :user, Orderflow.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(point, attrs) do
    point
    |> cast(attrs, [:points, :type, :description, :user_id])
    |> validate_required([:points, :type, :user_id])
    |> validate_number(:points, not_equal_to: 0)
    |> foreign_key_constraint(:user_id)
  end
end
