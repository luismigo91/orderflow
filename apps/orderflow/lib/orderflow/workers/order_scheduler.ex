defmodule Orderflow.Workers.OrderScheduler do
  @moduledoc """
  Oban worker that processes scheduled orders.
  """

  use Oban.Worker, queue: :default

  alias Orderflow.Orders
  alias Orderflow.Repo
  import Ecto.Query

  @impl Oban.Worker
  def perform(_job) do
    now = DateTime.utc_now()
    five_minutes_ago = DateTime.add(now, -5, :minute)

    orders =
      Orders.Order
      |> where(
        [o],
        o.schedule_status == "scheduled" and o.scheduled_for <= ^now and
          o.scheduled_for >= ^five_minutes_ago
      )
      |> Repo.all()

    for order <- orders do
      Orders.update_order(order, %{schedule_status: "immediate"})
    end

    :ok
  end
end
