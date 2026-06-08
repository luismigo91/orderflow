defmodule Orderflow.Loyalty.Tier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "loyalty_tiers" do
    field :name, :string
    field :min_points, :integer
    field :multiplier, :decimal
    field :benefits, {:array, :string}, default: []
    field :icon, :string
    field :active, :boolean, default: true

    has_many :user_loyalties, Orderflow.Loyalty.UserLoyalty, foreign_key: :current_tier_id

    timestamps(type: :utc_datetime)
  end

  def changeset(tier, attrs) do
    tier
    |> cast(attrs, [:name, :min_points, :multiplier, :benefits, :icon, :active])
    |> validate_required([:name, :min_points, :multiplier])
    |> validate_number(:min_points, greater_than_or_equal_to: 0)
    |> validate_number(:multiplier, greater_than: 0)
    |> unique_constraint(:name)
  end
end

defmodule Orderflow.Loyalty.UserLoyalty do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_loyalty" do
    field :total_points, :integer, default: 0
    field :available_points, :integer, default: 0
    field :lifetime_points, :integer, default: 0

    belongs_to :user, Orderflow.Accounts.User
    belongs_to :current_tier, Orderflow.Loyalty.Tier

    timestamps(type: :utc_datetime)
  end

  def changeset(user_loyalty, attrs) do
    user_loyalty
    |> cast(attrs, [
      :user_id,
      :current_tier_id,
      :total_points,
      :available_points,
      :lifetime_points
    ])
    |> validate_required([:user_id])
    |> validate_number(:total_points, greater_than_or_equal_to: 0)
    |> validate_number(:available_points, greater_than_or_equal_to: 0)
    |> validate_number(:lifetime_points, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:current_tier_id)
  end
end
