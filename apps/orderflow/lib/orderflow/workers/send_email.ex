defmodule Orderflow.Workers.SendEmail do
  @moduledoc """
  Oban worker for sending emails asynchronously.
  """
  use Oban.Worker, queue: :emails, max_attempts: 3

  alias Orderflow.Mailer
  alias Orderflow.Notifications.Emails

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => "order_confirmed", "order_id" => order_id}}) do
    order = Orderflow.Orders.get_order_with_items!(order_id)

    Emails.order_confirmed(order)
    |> Mailer.deliver()

    :ok
  end

  def perform(%Oban.Job{args: %{"type" => "order_on_the_way", "order_id" => order_id}}) do
    order = Orderflow.Orders.get_order_with_items!(order_id)

    Emails.order_on_the_way(order)
    |> Mailer.deliver()

    :ok
  end

  def perform(%Oban.Job{args: %{"type" => "order_delivered", "order_id" => order_id}}) do
    order = Orderflow.Orders.get_order_with_items!(order_id)

    Emails.order_delivered(order)
    |> Mailer.deliver()

    :ok
  end

  def perform(%Oban.Job{
        args: %{"type" => "admin_alert", "order_id" => order_id, "threshold" => threshold}
      }) do
    order = Orderflow.Orders.get_order_with_items!(order_id)

    Emails.admin_alert(order, :stuck, threshold)
    |> Mailer.deliver()

    :ok
  end
end
