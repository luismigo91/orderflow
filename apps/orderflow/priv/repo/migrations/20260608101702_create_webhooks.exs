defmodule Orderflow.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks) do
      add :url, :string, null: false
      add :events, {:array, :string}, default: []
      add :active, :boolean, default: true
      add :secret, :string

      timestamps()
    end
  end
end
