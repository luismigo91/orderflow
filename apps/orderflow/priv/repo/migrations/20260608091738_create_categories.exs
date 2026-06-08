defmodule Orderflow.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :description, :text
      add :sort_order, :integer, default: 0

      timestamps()
    end
  end
end
