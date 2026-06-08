defmodule Orderflow.Repo.Migrations.CreateFeatureFlags do
  use Ecto.Migration

  def change do
    create table(:feature_flags) do
      add :name, :string, null: false
      add :enabled, :boolean, default: false
      add :description, :string

      timestamps()
    end

    create unique_index(:feature_flags, [:name])
  end
end
