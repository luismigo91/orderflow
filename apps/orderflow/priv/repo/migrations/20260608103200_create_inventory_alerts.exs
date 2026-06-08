defmodule Orderflow.Repo.Migrations.CreateInventoryAlerts do
  use Ecto.Migration

  def change do
    create table(:inventory_alerts) do
      add :threshold, :integer, null: false
      add :current_stock, :integer, null: false
      add :resolved, :boolean, default: false
      add :product_id, references(:products, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:inventory_alerts, [:product_id])
    create index(:inventory_alerts, [:resolved])
  end
end
