defmodule Orderflow.Orders.OrderStatusLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_status_logs" do
    field :from_status, Ecto.Enum,
      values: [:pending, :confirmed, :cooking, :ready, :delivering, :delivered, :cancelled]

    field :to_status, Ecto.Enum,
      values: [:pending, :confirmed, :cooking, :ready, :delivering, :delivered, :cancelled]

    field :changed_by, :string
    field :reason, :string

    belongs_to :order, Orderflow.Orders.Order

    timestamps()
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [:from_status, :to_status, :changed_by, :reason, :order_id])
    |> validate_required([:from_status, :to_status, :changed_by, :order_id])
    |> validate_different_status()
    |> foreign_key_constraint(:order_id)
  end

  defp validate_different_status(changeset) do
    from = get_field(changeset, :from_status)
    to = get_field(changeset, :to_status)

    if from == to do
      add_error(changeset, :to_status, "debe ser diferente al estado anterior")
    else
      changeset
    end
  end
end
