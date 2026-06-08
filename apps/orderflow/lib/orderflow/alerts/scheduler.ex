defmodule Orderflow.Alerts.Scheduler do
  @moduledoc """
  GenServer that periodically checks for stuck orders and broadcasts alerts.
  """
  use GenServer

  alias Orderflow.Orders
  alias Orderflow.Inventory

  @check_interval :timer.minutes(5)
  @cooking_threshold 30
  @pending_threshold 10

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_check()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check, state) do
    check_stuck_orders()
    check_inventory()
    schedule_check()
    {:noreply, state}
  end

  defp check_stuck_orders do
    now = NaiveDateTime.utc_now()

    Orders.list_orders_by_status(:cooking)
    |> Enum.filter(fn order ->
      minutes_in_state = NaiveDateTime.diff(now, order.updated_at, :minute)
      minutes_in_state > @cooking_threshold
    end)
    |> Enum.each(&broadcast_alert(:cooking, &1))

    Orders.list_orders_by_status(:pending)
    |> Enum.filter(fn order ->
      minutes_in_state = NaiveDateTime.diff(now, order.updated_at, :minute)
      minutes_in_state > @pending_threshold
    end)
    |> Enum.each(&broadcast_alert(:pending, &1))
  end

  defp check_inventory do
    low_stock = Inventory.check_stock_levels()

    if length(low_stock) > 0 do
      Phoenix.PubSub.broadcast(
        Orderflow.PubSub,
        "admin:alerts",
        %{type: :low_stock, products: low_stock}
      )
    end
  end

  defp broadcast_alert(type, order) do
    Phoenix.PubSub.broadcast(
      Orderflow.PubSub,
      "admin:alerts",
      %{type: :stuck_order, order_type: type, order: order}
    )
  end

  defp schedule_check do
    Process.send_after(self(), :check, @check_interval)
  end
end
