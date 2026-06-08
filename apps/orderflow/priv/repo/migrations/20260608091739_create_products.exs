defmodule Orderflow.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :stock, :integer, default: 0
      add :active, :boolean, default: true
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps()
    end

    create index(:products, [:category_id])
  end
end
