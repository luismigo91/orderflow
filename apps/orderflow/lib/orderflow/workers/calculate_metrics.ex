defmodule Orderflow.Workers.CalculateMetrics do
  @moduledoc """
  Oban worker for calculating dashboard metrics.
  """
  use Oban.Worker, queue: :metrics

  alias Orderflow.Metrics.Collector

  @impl Oban.Worker
  def perform(_job) do
    Collector.refresh_metrics()
    :ok
  end
end
