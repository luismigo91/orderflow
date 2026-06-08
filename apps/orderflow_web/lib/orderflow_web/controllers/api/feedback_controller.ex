defmodule OrderflowWeb.Api.FeedbackController do
  use OrderflowWeb, :controller

  alias Orderflow.Feedback
  alias Orderflow.Feedback.Feedback, as: FeedbackItem

  def index(conn, _params) do
    feedback = Feedback.list_feedback()
    render(conn, :index, feedback: feedback)
  end

  def create(conn, %{"feedback" => feedback_params}) do
    with {:ok, %FeedbackItem{} = feedback} <- Feedback.create_feedback(feedback_params) do
      conn
      |> put_status(:created)
      |> render(:show, feedback: feedback)
    end
  end

  def stats(conn, _params) do
    nps = Feedback.nps_stats()
    ratings = Feedback.average_ratings()

    render(conn, :stats, nps: nps, ratings: ratings)
  end
end

defmodule OrderflowWeb.Api.FeedbackJSON do
  alias Orderflow.Feedback.Feedback

  def index(%{feedback: feedback}) do
    %{data: for(item <- feedback, do: data(item))}
  end

  def show(%{feedback: feedback}) do
    %{data: data(feedback)}
  end

  def stats(%{nps: nps, ratings: ratings}) do
    %{
      data: %{
        nps: nps,
        ratings: ratings
      }
    }
  end

  defp data(%Orderflow.Feedback.Feedback{} = feedback) do
    %{
      id: feedback.id,
      order_id: feedback.order_id,
      nps_score: feedback.nps_score,
      food_rating: feedback.food_rating,
      service_rating: feedback.service_rating,
      speed_rating: feedback.speed_rating,
      comments: feedback.comments,
      tags: feedback.tags,
      would_recommend: feedback.would_recommend,
      inserted_at: feedback.inserted_at
    }
  end
end
