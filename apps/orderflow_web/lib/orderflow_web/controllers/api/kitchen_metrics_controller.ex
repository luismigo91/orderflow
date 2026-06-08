defmodule OrderflowWeb.Api.KitchenMetricsController do
  use OrderflowWeb, :controller

  alias Orderflow.Kitchen

  def index(conn, _params) do
    metrics = Kitchen.list_metrics()
    render(conn, :index, metrics: metrics)
  end

  def stats(conn, _params) do
    avg_time = Kitchen.average_prep_time()
    throughput = Kitchen.throughput_by_hour()

    render(conn, :stats, avg_time: avg_time, throughput: throughput)
  end
end

defmodule OrderflowWeb.Api.KitchenMetricsJSON do
  def index(%{metrics: metrics}) do
    %{data: for(metric <- metrics, do: data(metric))}
  end

  def stats(%{avg_time: avg_time, throughput: throughput}) do
    %{
      data: %{
        average_prep_time: avg_time,
        throughput_by_hour: throughput
      }
    }
  end

  defp data(%Orderflow.Kitchen.Metrics{} = metric) do
    %{
      id: metric.id,
      order_id: metric.order_id,
      total_minutes: metric.total_minutes,
      items_count: metric.items_count,
      bottleneck_stage: metric.bottleneck_stage,
      stage_times: metric.stage_times,
      inserted_at: metric.inserted_at
    }
  end
end
