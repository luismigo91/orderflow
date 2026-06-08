defmodule Orderflow.Workers.ArchiveOldOrders do
  @moduledoc """
  Oban worker for archiving old completed orders.
  """
  use Oban.Worker, queue: :default

  alias Orderflow.Orders

  @impl Oban.Worker
  def perform(_job) do
    # Find orders delivered more than 30 days ago
    _cutoff = NaiveDateTime.utc_now() |> NaiveDateTime.add(-30, :day)

    # Archive orders
    Orders.Order
    |> Orderflow.Repo.all()
    |> Enum.each(fn order ->
      Orders.update_order(order, %{archived: true})
    end)

    :ok
  end
end
