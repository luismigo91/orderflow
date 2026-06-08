defmodule Orderflow.Repo.Migrations.AddOrderScheduling do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :scheduled_for, :utc_datetime
      add :schedule_status, :string, default: "immediate", null: false
    end

    create index(:orders, [:scheduled_for])
    create index(:orders, [:schedule_status])
  end
end
