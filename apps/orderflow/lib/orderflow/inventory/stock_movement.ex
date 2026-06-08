defmodule Orderflow.Inventory.StockMovement do
  @moduledoc """
  Schema for stock movements.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "stock_movements" do
    field :quantity, :integer
    field :type, Ecto.Enum, values: [:in, :out, :adjustment, :sale, :return, :damage]
    field :reason, :string

    belongs_to :product, Orderflow.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  def changeset(movement, attrs) do
    movement
    |> cast(attrs, [:quantity, :type, :reason, :product_id])
    |> validate_required([:quantity, :type, :product_id])
    |> foreign_key_constraint(:product_id)
  end
end
