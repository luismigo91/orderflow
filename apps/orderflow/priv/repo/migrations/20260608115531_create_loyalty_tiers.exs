defmodule Orderflow.Repo.Migrations.CreateLoyaltyTiers do
  use Ecto.Migration

  def change do
    create table(:loyalty_tiers) do
      add :name, :string, null: false
      add :min_points, :integer, null: false
      add :multiplier, :decimal, null: false, default: 1.0
      add :benefits, {:array, :string}, default: []
      add :icon, :string
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:loyalty_tiers, [:name])
    create index(:loyalty_tiers, [:min_points])

    create table(:user_loyalty) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :current_tier_id, references(:loyalty_tiers, on_delete: :nilify_all)
      add :total_points, :integer, default: 0, null: false
      add :available_points, :integer, default: 0, null: false
      add :lifetime_points, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_loyalty, [:user_id])
    create index(:user_loyalty, [:current_tier_id])
  end
end
