defmodule Orderflow.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :customer_name, :string
    field :customer_phone, :string
    field :total, :decimal

    field :status, Ecto.Enum,
      values: [:pending, :confirmed, :cooking, :ready, :delivering, :delivered, :cancelled],
      default: :pending

    field :notes, :string
    field :cancel_reason, :string
    field :estimated_ready_at, :naive_datetime
    field :estimated_delivery_at, :naive_datetime
    field :archived, :boolean, default: false

    belongs_to :user, Orderflow.Accounts.User
    belongs_to :assigned_user, Orderflow.Accounts.User

    has_many :order_items, Orderflow.Orders.OrderItem
    has_many :status_logs, Orderflow.Orders.OrderStatusLog

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :customer_name,
      :customer_phone,
      :total,
      :status,
      :notes,
      :cancel_reason,
      :user_id,
      :assigned_user_id
    ])
    |> validate_required([:customer_name, :customer_phone, :status])
    |> validate_length(:customer_name, min: 1, max: 200)
    |> validate_number(:total, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:assigned_user_id)
  end

  def status_changeset(order, attrs) do
    order
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  def calculate_total(order) do
    order.order_items
    |> Enum.reduce(Decimal.new("0.00"), fn item, acc ->
      Decimal.add(acc, item.subtotal)
    end)
  end
end
