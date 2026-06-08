defmodule Orderflow.Repo.Migrations.CreateOrderSplits do
  use Ecto.Migration

  def change do
    create table(:order_splits) do
      add :order_id, references(:orders, on_delete: :delete_all)
      add :split_type, :string, null: false
      add :total_splits, :integer, null: false
      add :status, :string, default: "pending", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:order_splits, [:order_id])

    create table(:split_payments) do
      add :order_split_id, references(:order_splits, on_delete: :delete_all)
      add :amount, :decimal, null: false
      add :paid_by, :string
      add :status, :string, default: "pending", null: false
      add :paid_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:split_payments, [:order_split_id])
  end
end
