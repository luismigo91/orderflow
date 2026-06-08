defmodule Orderflow.Loyalty do
  @moduledoc """
  Context for loyalty points system.
  """
  import Ecto.Query

  alias Orderflow.Loyalty.Point
  alias Orderflow.Loyalty.{Tier, UserLoyalty}
  alias Orderflow.Repo

  @doc """
  Award points for an order. 1 point per $1 spent.
  """
  def award_points(user_id, order_total) when is_integer(user_id) do
    points = trunc(Decimal.to_float(order_total))

    %Point{}
    |> Point.changeset(%{
      user_id: user_id,
      points: points,
      type: :earned,
      description: "Points earned from order"
    })
    |> Repo.insert()
  end

  @doc """
  Redeem points for a discount.
  100 points = $1 discount.
  """
  def redeem_points(user_id, points_to_redeem) when is_integer(user_id) do
    current_balance = get_balance(user_id)

    if current_balance >= points_to_redeem do
      %Point{}
      |> Point.changeset(%{
        user_id: user_id,
        points: -points_to_redeem,
        type: :redeemed,
        description: "Points redeemed for discount"
      })
      |> Repo.insert()
    else
      {:error, :insufficient_points}
    end
  end

  @doc """
  Get current point balance for a user.
  """
  def get_balance(user_id) do
    Point
    |> where([p], p.user_id == ^user_id)
    |> select([p], sum(p.points))
    |> Repo.one()
    |> case do
      nil -> 0
      balance -> balance
    end
  end

  @doc """
  Get transaction history for a user.
  """
  def list_transactions(user_id) do
    Point
    |> where([p], p.user_id == ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  # Tier management

  def list_tiers do
    Tier |> where([t], t.active == true) |> order_by([t], t.min_points) |> Repo.all()
  end

  def get_tier!(id), do: Repo.get!(Tier, id)

  def create_tier(attrs) do
    %Tier{}
    |> Tier.changeset(attrs)
    |> Repo.insert()
  end

  def update_tier(%Tier{} = tier, attrs) do
    tier
    |> Tier.changeset(attrs)
    |> Repo.update()
  end

  def change_tier(%Tier{} = tier, attrs \\ %{}), do: Tier.changeset(tier, attrs)

  def get_user_loyalty(user_id) do
    UserLoyalty
    |> where([ul], ul.user_id == ^user_id)
    |> preload(:current_tier)
    |> Repo.one()
  end

  def create_user_loyalty(attrs) do
    %UserLoyalty{}
    |> UserLoyalty.changeset(attrs)
    |> Repo.insert()
  end

  def add_user_points(user_id, points) do
    user_loyalty = get_user_loyalty(user_id)

    if user_loyalty do
      new_lifetime = user_loyalty.lifetime_points + points
      new_available = user_loyalty.available_points + points
      new_total = user_loyalty.total_points + points

      tier = determine_tier(new_total)
      tier_id = if tier, do: tier.id, else: user_loyalty.current_tier_id

      user_loyalty
      |> UserLoyalty.changeset(%{
        lifetime_points: new_lifetime,
        available_points: new_available,
        total_points: new_total,
        current_tier_id: tier_id
      })
      |> Repo.update()
    else
      create_user_loyalty(%{
        user_id: user_id,
        total_points: points,
        available_points: points,
        lifetime_points: points
      })
    end
  end

  def redeem_user_points(user_id, points) do
    user_loyalty = get_user_loyalty(user_id)

    if user_loyalty && user_loyalty.available_points >= points do
      user_loyalty
      |> UserLoyalty.changeset(%{
        available_points: user_loyalty.available_points - points
      })
      |> Repo.update()
    else
      {:error, :insufficient_points}
    end
  end

  defp determine_tier(points) do
    Tier
    |> where([t], t.active == true and t.min_points <= ^points)
    |> order_by([t], desc: t.min_points)
    |> limit(1)
    |> Repo.one()
  end
end
