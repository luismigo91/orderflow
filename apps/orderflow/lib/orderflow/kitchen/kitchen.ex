defmodule Orderflow.Kitchen do
  @moduledoc """
  Context for kitchen efficiency metrics.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Kitchen.Metrics

  def list_metrics do
    Metrics
    |> preload(:order)
    |> order_by([m], desc: m.inserted_at)
    |> Repo.all()
  end

  def get_metrics!(id), do: Repo.get!(Metrics, id) |> Repo.preload(:order)

  def create_metrics(attrs) do
    %Metrics{}
    |> Metrics.changeset(attrs)
    |> Repo.insert()
  end

  def calculate_order_metrics(order_id, stage_times) do
    total =
      stage_times
      |> Map.values()
      |> Enum.sum()

    bottleneck =
      stage_times
      |> Enum.max_by(fn {_k, v} -> v end, fn -> {nil, 0} end)
      |> elem(0)

    %Metrics{}
    |> Metrics.changeset(%{
      order_id: order_id,
      stage_times: stage_times,
      total_minutes: total,
      bottleneck_stage: bottleneck
    })
    |> Repo.insert()
  end

  def average_prep_time do
    Metrics
    |> where([m], not is_nil(m.total_minutes))
    |> select([m], avg(m.total_minutes))
    |> Repo.one()
    |> case do
      nil -> 0.0
      val -> Decimal.to_float(val)
    end
  end

  def throughput_by_hour do
    Metrics
    |> join(:inner, [m], o in assoc(m, :order))
    |> select([m, o], %{
      hour: fragment("EXTRACT(hour FROM ?)", o.inserted_at),
      count: count(m.id)
    })
    |> group_by([m, o], fragment("EXTRACT(hour FROM ?)", o.inserted_at))
    |> Repo.all()
  end
end
