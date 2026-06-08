defmodule Orderflow.Pipelines.OrderProcessor do
  @moduledoc """
  GenStage pipeline for batch processing orders.
  """
  use GenStage

  alias Orderflow.Orders

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:producer_consumer, %{},
     subscribe_to: [{Orderflow.Pipelines.OrderProducer, min_demand: 1, max_demand: 10}]}
  end

  def handle_events(orders, _from, state) do
    processed =
      Enum.map(orders, fn order ->
        # Process order: calculate final metrics, send notifications, etc.
        Orders.get_order_with_items!(order.id)
      end)

    {:noreply, processed, state}
  end
end

## Producer

defmodule Orderflow.Pipelines.OrderProducer do
  @moduledoc """
  GenStage producer for orders.
  """
  use GenStage

  alias Orderflow.Orders

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:producer, state}
  end

  def handle_demand(demand, state) when demand > 0 do
    orders = Orders.list_orders() |> Enum.take(demand)
    {:noreply, orders, state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
