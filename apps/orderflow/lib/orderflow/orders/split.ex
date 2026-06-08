defmodule Orderflow.Orders.Split do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_splits" do
    field :split_type, Ecto.Enum, values: [:equal, :percentage, :items], default: :equal
    field :total_splits, :integer
    field :status, Ecto.Enum, values: [:pending, :partial, :complete], default: :pending

    belongs_to :order, Orderflow.Orders.Order
    has_many :split_payments, Orderflow.Orders.SplitPayment, foreign_key: :order_split_id

    timestamps(type: :utc_datetime)
  end

  def changeset(split, attrs) do
    split
    |> cast(attrs, [:order_id, :split_type, :total_splits, :status])
    |> validate_required([:order_id, :split_type, :total_splits])
    |> validate_number(:total_splits, greater_than: 1)
    |> foreign_key_constraint(:order_id)
  end
end

defmodule Orderflow.Orders.SplitPayment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "split_payments" do
    field :amount, :decimal
    field :paid_by, :string
    field :status, Ecto.Enum, values: [:pending, :paid], default: :pending
    field :paid_at, :utc_datetime
    field :order_split_id, :id

    timestamps(type: :utc_datetime)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:order_split_id, :amount, :paid_by, :status, :paid_at])
    |> validate_required([:order_split_id, :amount])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:order_split_id)
  end
end
