defmodule Orderflow.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :quantity, :integer, null: false
      add :unit_price, :decimal, null: false
      add :subtotal, :decimal
      add :notes, :text
      add :order_id, references(:orders, on_delete: :delete_all)
      add :product_id, references(:products, on_delete: :nilify_all)

      timestamps()
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])
  end
end
