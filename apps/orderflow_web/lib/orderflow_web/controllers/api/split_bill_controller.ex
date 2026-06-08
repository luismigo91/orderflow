defmodule OrderflowWeb.Api.SplitBillController do
  use OrderflowWeb, :controller

  alias Orderflow.Orders
  alias Orderflow.Orders.Splits

  def create(conn, %{
        "order_id" => order_id,
        "split_type" => split_type,
        "total_splits" => total_splits
      }) do
    order = Orders.get_order!(order_id)

    with {:ok, split} <-
           Splits.create_split(order, String.to_atom(split_type), String.to_integer(total_splits)) do
      conn
      |> put_status(:created)
      |> render(:show, split: split)
    end
  end

  def show(conn, %{"id" => id}) do
    split = Splits.get_split!(id)
    render(conn, :show, split: split)
  end

  def mark_paid(conn, %{"payment_id" => payment_id, "paid_by" => paid_by}) do
    payment = Orders.get_split_payment!(payment_id)

    with {:ok, _} <- Splits.mark_payment_paid(payment, paid_by) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule OrderflowWeb.Api.SplitBillJSON do
  def show(%{split: split}) do
    %{data: data(split)}
  end

  defp data(split) do
    %{
      id: split.id,
      order_id: split.order_id,
      split_type: split.split_type,
      total_splits: split.total_splits,
      status: split.status,
      payments: for(payment <- split.split_payments, do: payment_data(payment))
    }
  end

  defp payment_data(payment) do
    %{
      id: payment.id,
      amount: payment.amount,
      paid_by: payment.paid_by,
      status: payment.status,
      paid_at: payment.paid_at
    }
  end
end
