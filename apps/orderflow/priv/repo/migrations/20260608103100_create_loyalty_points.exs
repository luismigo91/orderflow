defmodule Orderflow.Repo.Migrations.CreateLoyaltyPoints do
  use Ecto.Migration

  def change do
    create table(:loyalty_points) do
      add :points, :integer, null: false
      add :type, :string, null: false
      add :description, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:loyalty_points, [:user_id])
    create index(:loyalty_points, [:type])
  end
end
