defmodule Orderflow.Repo.Migrations.CreatePromotions do
  use Ecto.Migration

  def change do
    create table(:promotions) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :value, :decimal, null: false
      add :min_order_amount, :decimal, default: "0"
      add :max_uses, :integer
      add :uses_count, :integer, default: 0
      add :active, :boolean, default: true
      add :expires_at, :naive_datetime

      timestamps()
    end

    create unique_index(:promotions, [:code])
  end
end
