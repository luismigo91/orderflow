defmodule Orderflow.Feedback.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback" do
    field :nps_score, :integer
    field :food_rating, :integer
    field :service_rating, :integer
    field :speed_rating, :integer
    field :comments, :string
    field :tags, {:array, :string}, default: []
    field :would_recommend, :boolean

    belongs_to :order, Orderflow.Orders.Order
    belongs_to :user, Orderflow.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [
      :order_id,
      :user_id,
      :nps_score,
      :food_rating,
      :service_rating,
      :speed_rating,
      :comments,
      :tags,
      :would_recommend
    ])
    |> validate_required([:order_id])
    |> validate_number(:nps_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 10)
    |> validate_number(:food_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:service_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:speed_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:user_id)
  end

  def nps_category(score) when score >= 9, do: :promoter
  def nps_category(score) when score >= 7, do: :passive
  def nps_category(score) when score >= 0, do: :detractor
  def nps_category(_), do: :unknown
end
