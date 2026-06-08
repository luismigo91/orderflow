defmodule Orderflow.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:tables) do
      add :number, :string, null: false
      add :capacity, :integer, null: false
      add :status, :string, default: "free", null: false
      add :location, :string
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tables, [:number])
    create index(:tables, [:status])
    create index(:tables, [:active])

    create table(:reservations) do
      add :table_id, references(:tables, on_delete: :delete_all)
      add :customer_name, :string, null: false
      add :customer_phone, :string
      add :party_size, :integer, null: false
      add :datetime, :utc_datetime, null: false
      add :status, :string, default: "confirmed", null: false
      add :notes, :text
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:reservations, [:table_id])
    create index(:reservations, [:datetime])
    create index(:reservations, [:status])
  end
end
