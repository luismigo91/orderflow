defmodule Orderflow.Metrics.Collector do
  @moduledoc """
  GenServer que recopila y cachea métricas del dashboard.
  """
  use GenServer

  alias Orderflow.Orders
  alias Orderflow.Repo
  import Ecto.Query

  @table :metrics_cache
  @tick_interval :timer.minutes(5)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :ets.new(@table, [:set, :public, :named_table])
    schedule_tick()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:tick, state) do
    calculate_and_cache_metrics()
    schedule_tick()
    {:noreply, state}
  end

  def get_dashboard_metrics do
    case :ets.lookup(@table, :dashboard) do
      [{:dashboard, metrics}] -> metrics
      [] -> calculate_metrics()
    end
  end

  def refresh_metrics do
    send(__MODULE__, :tick)
  end

  defp calculate_and_cache_metrics do
    metrics = calculate_metrics()
    :ets.insert(@table, {:dashboard, metrics})
  end

  defp calculate_metrics do
    today = Date.utc_today()
    today_start = NaiveDateTime.new!(today, ~T[00:00:00])
    today_end = NaiveDateTime.new!(Date.add(today, 1), ~T[00:00:00])

    orders_today =
      Orders.Order
      |> where([o], o.inserted_at >= ^today_start and o.inserted_at < ^today_end)
      |> Repo.aggregate(:count)

    revenue_today =
      Orders.Order
      |> where([o], o.inserted_at >= ^today_start and o.inserted_at < ^today_end)
      |> where([o], o.status in [:delivered, :delivering, :ready])
      |> select([o], sum(o.total))
      |> Repo.one() || Decimal.new("0.00")

    active_orders =
      Orders.Order
      |> where([o], o.status in [:pending, :confirmed, :cooking, :ready, :delivering])
      |> Repo.aggregate(:count)

    orders_by_status =
      Orders.Order
      |> where([o], o.inserted_at >= ^today_start and o.inserted_at < ^today_end)
      |> group_by([o], o.status)
      |> select([o], {o.status, count(o.id)})
      |> Repo.all()
      |> Enum.into(%{})

    %{
      orders_today: orders_today,
      revenue_today: revenue_today,
      active_orders: active_orders,
      orders_by_status: orders_by_status
    }
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end
end
