defmodule Orderflow.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :quantity, :integer, default: 1
    field :unit_price, :decimal
    field :subtotal, :decimal
    field :notes, :string

    belongs_to :order, Orderflow.Orders.Order
    belongs_to :product, Orderflow.Catalog.Product

    timestamps()
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:quantity, :unit_price, :subtotal, :notes, :order_id, :product_id])
    |> validate_required([:quantity, :unit_price, :product_id])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than: 0)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:product_id)
    |> calculate_subtotal()
  end

  defp calculate_subtotal(changeset) do
    case {get_field(changeset, :quantity), get_field(changeset, :unit_price)} do
      {qty, price} when is_integer(qty) and not is_nil(price) ->
        subtotal = Decimal.mult(Decimal.new(price), Decimal.new(qty))
        put_change(changeset, :subtotal, subtotal)

      _ ->
        changeset
    end
  end
end
