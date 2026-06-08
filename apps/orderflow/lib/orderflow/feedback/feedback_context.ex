defmodule Orderflow.Feedback do
  @moduledoc """
  Context for customer feedback and NPS.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Feedback.Feedback

  def list_feedback do
    Feedback
    |> preload([:order, :user])
    |> order_by([f], desc: f.inserted_at)
    |> Repo.all()
  end

  def get_feedback!(id), do: Repo.get!(Feedback, id) |> Repo.preload([:order, :user])

  def create_feedback(attrs) do
    %Feedback{}
    |> Feedback.changeset(attrs)
    |> Repo.insert()
  end

  def change_feedback(%Feedback{} = feedback, attrs \\ %{}),
    do: Feedback.changeset(feedback, attrs)

  def nps_stats do
    feedbacks =
      Feedback
      |> where([f], not is_nil(f.nps_score))
      |> Repo.all()

    total = length(feedbacks)

    if total > 0 do
      promoters = Enum.count(feedbacks, &(&1.nps_score >= 9))
      passives = Enum.count(feedbacks, &(&1.nps_score >= 7 and &1.nps_score < 9))
      detractors = Enum.count(feedbacks, &(&1.nps_score < 7))

      nps = round((promoters - detractors) / total * 100)

      %{
        total: total,
        promoters: promoters,
        passives: passives,
        detractors: detractors,
        nps: nps
      }
    else
      %{total: 0, promoters: 0, passives: 0, detractors: 0, nps: 0}
    end
  end

  def average_ratings do
    Feedback
    |> select([f], %{
      food: avg(f.food_rating),
      service: avg(f.service_rating),
      speed: avg(f.speed_rating)
    })
    |> Repo.one()
    |> case do
      nil -> %{food: 0.0, service: 0.0, speed: 0.0}
      result -> result
    end
  end
end
