defmodule Orderflow.Orders.Splits do
  @moduledoc """
  Context for split bill functionality.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Orders.{Split, SplitPayment, Order}

  def get_split!(id), do: Repo.get!(Split, id) |> Repo.preload(:split_payments)

  def get_split_for_order(order_id) do
    Split
    |> where([s], s.order_id == ^order_id)
    |> preload(:split_payments)
    |> Repo.one()
  end

  def create_split(%Order{} = order, split_type, total_splits) do
    total = order.total

    split =
      %Split{}
      |> Split.changeset(%{
        order_id: order.id,
        split_type: split_type,
        total_splits: total_splits
      })
      |> Repo.insert!()

    payments =
      case split_type do
        :equal ->
          amount = Decimal.div(total, total_splits)

          for _ <- 1..total_splits do
            %SplitPayment{}
            |> SplitPayment.changeset(%{
              order_split_id: split.id,
              amount: amount,
              status: :pending
            })
            |> Repo.insert!()
          end

        :percentage ->
          percentage = Decimal.div(Decimal.new(100), total_splits)
          amount = Decimal.mult(total, Decimal.div(percentage, 100))

          for _ <- 1..total_splits do
            %SplitPayment{}
            |> SplitPayment.changeset(%{
              order_split_id: split.id,
              amount: amount,
              status: :pending
            })
            |> Repo.insert!()
          end

        _ ->
          []
      end

    {:ok, %{split | split_payments: payments}}
  end

  def mark_payment_paid(%SplitPayment{} = payment, paid_by) do
    now = DateTime.utc_now()

    payment
    |> SplitPayment.changeset(%{
      status: :paid,
      paid_by: paid_by,
      paid_at: now
    })
    |> Repo.update()
    |> maybe_update_split_status()
  end

  defp maybe_update_split_status({:ok, payment}) do
    split = get_split!(payment.order_split_id)
    all_paid = Enum.all?(split.split_payments, &(&1.status == :paid))

    if all_paid do
      split
      |> Split.changeset(%{status: :complete})
      |> Repo.update()
    else
      any_paid = Enum.any?(split.split_payments, &(&1.status == :paid))

      if any_paid do
        split
        |> Split.changeset(%{status: :partial})
        |> Repo.update()
      else
        {:ok, split}
      end
    end
  end

  defp maybe_update_split_status(error), do: error
end
