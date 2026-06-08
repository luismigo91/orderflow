defmodule Orderflow.Repo.Migrations.CreateStockMovements do
  use Ecto.Migration

  def change do
    create table(:stock_movements) do
      add :quantity, :integer, null: false
      add :type, :string, null: false
      add :reason, :text
      add :product_id, references(:products, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:stock_movements, [:product_id])
    create index(:stock_movements, [:type])
    create index(:stock_movements, [:inserted_at])
  end
end
