defmodule Orderflow.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :date, :date, null: false
      add :start_time, :time, null: false
      add :end_time, :time, null: false
      add :role, :string, null: false
      add :status, :string, default: "scheduled", null: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:shifts, [:user_id])
    create index(:shifts, [:date])
    create index(:shifts, [:role])

    create table(:shift_requests) do
      add :shift_id, references(:shifts, on_delete: :delete_all)
      add :requester_id, references(:users, on_delete: :delete_all)
      add :type, :string, null: false
      add :status, :string, default: "pending", null: false
      add :reason, :text
      add :target_shift_id, references(:shifts, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:shift_requests, [:shift_id])
    create index(:shift_requests, [:requester_id])
    create index(:shift_requests, [:status])
  end
end
