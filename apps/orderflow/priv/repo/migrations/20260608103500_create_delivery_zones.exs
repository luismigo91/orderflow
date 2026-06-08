defmodule Orderflow.Repo.Migrations.CreateDeliveryZones do
  use Ecto.Migration

  def change do
    create table(:delivery_zones) do
      add :name, :string, null: false
      add :description, :text
      add :min_lat, :float, null: false
      add :max_lat, :float, null: false
      add :min_lng, :float, null: false
      add :max_lng, :float, null: false
      add :delivery_fee, :decimal
      add :estimated_time_minutes, :integer
      add :active, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create index(:delivery_zones, [:active])
  end
end
