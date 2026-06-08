defmodule Orderflow.Repo.Migrations.AddArchivedToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :archived, :boolean, default: false
    end
  end
end
