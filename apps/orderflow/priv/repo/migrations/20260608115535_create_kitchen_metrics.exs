defmodule Orderflow.Repo.Migrations.CreateKitchenMetrics do
  use Ecto.Migration

  def change do
    create table(:kitchen_metrics) do
      add :order_id, references(:orders, on_delete: :delete_all)
      add :prep_start, :utc_datetime
      add :prep_end, :utc_datetime
      add :stage_times, :map, default: %{}
      add :total_minutes, :integer
      add :items_count, :integer
      add :bottleneck_stage, :string

      timestamps(type: :utc_datetime)
    end

    create index(:kitchen_metrics, [:order_id])
    create index(:kitchen_metrics, [:total_minutes])
  end
end
