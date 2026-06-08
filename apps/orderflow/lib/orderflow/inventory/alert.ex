defmodule Orderflow.Inventory.Alert do
  @moduledoc """
  Schema for low stock alerts.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_alerts" do
    field :threshold, :integer
    field :current_stock, :integer
    field :resolved, :boolean, default: false

    belongs_to :product, Orderflow.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:threshold, :current_stock, :resolved, :product_id])
    |> validate_required([:threshold, :current_stock, :product_id])
    |> foreign_key_constraint(:product_id)
  end
end
