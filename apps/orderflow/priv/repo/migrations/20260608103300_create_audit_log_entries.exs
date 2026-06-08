defmodule Orderflow.Repo.Migrations.CreateAuditLogEntries do
  use Ecto.Migration

  def change do
    create table(:audit_log_entries) do
      add :action, :string, null: false
      add :resource_type, :string, null: false
      add :resource_id, :string
      add :metadata, :map, default: "{}"
      add :ip_address, :string
      add :user_id, references(:users, on_delete: :nilify_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:audit_log_entries, [:user_id])
    create index(:audit_log_entries, [:resource_type, :resource_id])
    create index(:audit_log_entries, [:inserted_at])
  end
end
