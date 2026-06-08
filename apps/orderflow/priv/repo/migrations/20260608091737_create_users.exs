defmodule Orderflow.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :name, :string, null: false
      add :role, :string, null: false
      add :phone, :string
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
