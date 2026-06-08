defmodule Orderflow.Monitoring.Alerts do
  @moduledoc """
  Advanced monitoring and alerting system.
  """
  use GenServer

  alias Orderflow.Orders

  @check_interval :timer.minutes(1)
  # minutes
  @order_timeout_threshold 30
  @error_threshold 5

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_check()
    {:ok, %{errors: [], last_alert: nil}}
  end

  @impl true
  def handle_info(:check, state) do
    new_state =
      state
      |> check_stuck_orders()
      |> check_error_rate()
      |> check_system_health()

    schedule_check()
    {:noreply, new_state}
  end

  defp check_stuck_orders(state) do
    now = NaiveDateTime.utc_now()

    stuck =
      Orders.list_orders_by_status(:cooking)
      |> Enum.filter(fn order ->
        minutes = NaiveDateTime.diff(now, order.updated_at, :minute)
        minutes > @order_timeout_threshold
      end)

    if length(stuck) > 0 do
      alert = %{
        type: :stuck_orders,
        message: "#{length(stuck)} orders stuck in cooking for > #{@order_timeout_threshold}m",
        severity: :warning,
        timestamp: now
      }

      broadcast_alert(alert)
      %{state | errors: [alert | state.errors] |> Enum.take(50)}
    else
      state
    end
  end

  defp check_error_rate(state) do
    # Check recent error count
    recent_errors =
      state.errors
      |> Enum.filter(fn error ->
        NaiveDateTime.diff(NaiveDateTime.utc_now(), error.timestamp, :minute) < 5
      end)

    if length(recent_errors) > @error_threshold do
      alert = %{
        type: :high_error_rate,
        message: "#{length(recent_errors)} errors in last 5 minutes",
        severity: :critical,
        timestamp: NaiveDateTime.utc_now()
      }

      broadcast_alert(alert)
      state
    else
      state
    end
  end

  defp check_system_health(state) do
    # Check memory usage
    memory = :erlang.memory(:total)
    memory_mb = div(memory, 1024 * 1024)

    if memory_mb > 500 do
      alert = %{
        type: :high_memory,
        message: "Memory usage: #{memory_mb}MB",
        severity: :warning,
        timestamp: NaiveDateTime.utc_now()
      }

      broadcast_alert(alert)
      state
    else
      state
    end
  end

  defp broadcast_alert(alert) do
    Phoenix.PubSub.broadcast(
      Orderflow.PubSub,
      "monitoring:alerts",
      %{event: "alert", alert: alert}
    )
  end

  defp schedule_check do
    Process.send_after(self(), :check, @check_interval)
  end
end
