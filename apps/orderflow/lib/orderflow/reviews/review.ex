defmodule Orderflow.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :rating, :integer
    field :comment, :string
    field :customer_name, :string

    belongs_to :order, Orderflow.Orders.Order
    belongs_to :product, Orderflow.Catalog.Product

    timestamps()
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rating, :comment, :customer_name, :order_id, :product_id])
    |> validate_required([:rating, :customer_name])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
  end
end
