defmodule Orderflow.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :stock, :integer, default: 0
    field :active, :boolean, default: true
    field :deleted_at, :naive_datetime

    belongs_to :category, Orderflow.Catalog.Category

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :stock, :active, :category_id])
    |> validate_required([:name, :price, :category_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_number(:price, greater_than: 0, message: "debe ser mayor que 0")
    |> validate_number(:stock, greater_than_or_equal_to: 0, message: "no puede ser negativo")
    |> foreign_key_constraint(:category_id)
  end
end
