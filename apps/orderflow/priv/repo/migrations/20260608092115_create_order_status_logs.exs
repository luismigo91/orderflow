defmodule Orderflow.Repo.Migrations.CreateOrderStatusLogs do
  use Ecto.Migration

  def change do
    create table(:order_status_logs) do
      add :from_status, :string, null: false
      add :to_status, :string, null: false
      add :changed_by, :string, null: false
      add :reason, :text
      add :order_id, references(:orders, on_delete: :delete_all)

      timestamps()
    end

    create index(:order_status_logs, [:order_id])
  end
end
