defmodule Orderflow.Repo.Migrations.CreateQrMenus do
  use Ecto.Migration

  def change do
    create table(:qr_menus) do
      add :code, :string, null: false
      add :table_id, references(:tables, on_delete: :delete_all)
      add :url, :string, null: false
      add :active, :boolean, default: true, null: false
      add :expires_at, :utc_datetime
      add :scan_count, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:qr_menus, [:code])
    create index(:qr_menus, [:table_id])
    create index(:qr_menus, [:active])
  end
end
