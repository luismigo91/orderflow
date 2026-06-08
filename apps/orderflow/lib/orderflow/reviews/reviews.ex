defmodule Orderflow.Reviews do
  @moduledoc """
  Contexto de reviews y ratings.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Reviews.Review

  def list_reviews do
    Repo.all(Review)
  end

  def list_reviews_by_product(product_id) do
    Review
    |> where([r], r.product_id == ^product_id)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end

  def get_average_rating(product_id) do
    Review
    |> where([r], r.product_id == ^product_id)
    |> select([r], avg(r.rating))
    |> Repo.one() || 0
  end

  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end
end
