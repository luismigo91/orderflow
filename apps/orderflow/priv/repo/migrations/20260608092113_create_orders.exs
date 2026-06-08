defmodule Orderflow.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :customer_name, :string, null: false
      add :customer_phone, :string, null: false
      add :total, :decimal
      add :status, :string, null: false, default: "pending"
      add :notes, :text
      add :cancel_reason, :text
      add :estimated_ready_at, :naive_datetime
      add :estimated_delivery_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nilify_all)
      add :assigned_user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:orders, [:status])
    create index(:orders, [:user_id])
    create index(:orders, [:assigned_user_id])
  end
end
