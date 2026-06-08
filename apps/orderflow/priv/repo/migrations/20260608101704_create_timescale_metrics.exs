defmodule Orderflow.Repo.Migrations.CreateTimescaleMetrics do
  use Ecto.Migration

  def up do
    create table(:timescale_metrics, primary_key: false) do
      add :timestamp, :naive_datetime, null: false
      add :metric_type, :string, null: false
      add :value, :decimal, null: false
      add :metadata, :map, default: %{}
    end

    # TimescaleDB extension - uncomment if using TimescaleDB
    # execute("SELECT create_hypertable('timescale_metrics', 'timestamp')")
  end

  def down do
    drop table(:timescale_metrics)
  end
end
