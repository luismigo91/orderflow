defmodule Orderflow.Repo.Migrations.AddSoftDeleteToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :deleted_at, :naive_datetime
    end

    create index(:products, [:deleted_at])
  end
end
