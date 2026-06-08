defmodule Orderflow.Notifications.OrderNotifier do
  @moduledoc """
  GenServer that sends notifications based on order state changes.
  """
  use GenServer

  @topic "orders:lobby"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Orderflow.PubSub, @topic)
    {:ok, %{}}
  end

  @impl true
  def handle_info(%{event: "order_updated", order: order}, state) do
    send_notification(order)
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp send_notification(order) do
    case order.status do
      :cooking ->
        %{"type" => "order_confirmed", "order_id" => order.id}
        |> Orderflow.Workers.SendEmail.new()
        |> Oban.insert()

      :delivering ->
        %{"type" => "order_on_the_way", "order_id" => order.id}
        |> Orderflow.Workers.SendEmail.new()
        |> Oban.insert()

      :delivered ->
        %{"type" => "order_delivered", "order_id" => order.id}
        |> Orderflow.Workers.SendEmail.new()
        |> Oban.insert()

      _ ->
        :ok
    end
  end
end
