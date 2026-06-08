defmodule Orderflow.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :sort_order, :integer, default: 0

    has_many :products, Orderflow.Catalog.Product

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :sort_order])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
  end
end
