defmodule Orderflow.Analytics.Predictive do
  @moduledoc """
  Predictive analytics for order trends and forecasting.
  """
  import Ecto.Query

  alias Orderflow.Orders.Order
  alias Orderflow.Repo

  @doc """
  Predict peak hours based on historical data.
  """
  def predict_peak_hours(days_back \\ 30) do
    start_date = DateTime.utc_now() |> DateTime.add(-days_back * 86400)

    Order
    |> where([o], o.inserted_at >= ^start_date)
    |> group_by([o], fragment("EXTRACT(HOUR FROM ?)", o.inserted_at))
    |> select([o], {fragment("EXTRACT(HOUR FROM ?)", o.inserted_at), count(o.id)})
    |> Repo.all()
    |> Enum.sort_by(fn {_, count} -> count end, :desc)
    |> Enum.take(3)
  end

  @doc """
  Predict busy days (0=Sunday, 6=Saturday).
  """
  def predict_busy_days(days_back \\ 30) do
    start_date = DateTime.utc_now() |> DateTime.add(-days_back * 86400)

    Order
    |> where([o], o.inserted_at >= ^start_date)
    |> group_by([o], fragment("EXTRACT(DOW FROM ?)", o.inserted_at))
    |> select([o], {fragment("EXTRACT(DOW FROM ?)", o.inserted_at), count(o.id)})
    |> Repo.all()
    |> Enum.sort_by(fn {_, count} -> count end, :desc)
  end

  @doc """
  Forecast revenue for next N days based on historical average.
  """
  def forecast_revenue(days_to_forecast \\ 7, days_back \\ 30) do
    start_date = DateTime.utc_now() |> DateTime.add(-days_back * 86400)

    avg_daily =
      Order
      |> where([o], o.inserted_at >= ^start_date)
      |> where([o], o.status in [:delivered, :ready])
      |> select([o], avg(o.total))
      |> Repo.one()
      |> case do
        nil -> Decimal.new("0")
        avg -> avg
      end

    forecast =
      for day <- 1..days_to_forecast do
        date = DateTime.utc_now() |> DateTime.add(day * 86400) |> DateTime.to_date()
        %{date: date, predicted_revenue: avg_daily}
      end

    %{
      avg_daily_revenue: avg_daily,
      forecast: forecast,
      total_predicted: Decimal.mult(avg_daily, Decimal.new(days_to_forecast))
    }
  end

  @doc """
  Get order velocity (orders per hour for last 24h).
  """
  def order_velocity do
    last_24h = DateTime.utc_now() |> DateTime.add(-86400)

    Order
    |> where([o], o.inserted_at >= ^last_24h)
    |> select([o], count(o.id))
    |> Repo.one()
    |> case do
      0 -> 0.0
      count -> count / 24.0
    end
  end

  @doc """
  Predict inventory needs for next week.
  """
  def predict_inventory_needs do
    # Get average items sold per day for last 7 days
    last_7d = DateTime.utc_now() |> DateTime.add(-7 * 86400)

    Order
    |> join(:inner, [o], oi in Orderflow.Orders.OrderItem, on: oi.order_id == o.id)
    |> where([o, _], o.inserted_at >= ^last_7d)
    |> where([o, _], o.status in [:delivered, :ready, :cooking])
    |> group_by([_, oi], oi.product_id)
    |> select([_, oi], {oi.product_id, sum(oi.quantity)})
    |> Repo.all()
    |> Enum.map(fn {product_id, avg_sold} ->
      %{product_id: product_id, avg_daily: avg_sold / 7, weekly_need: avg_sold}
    end)
  end
end
