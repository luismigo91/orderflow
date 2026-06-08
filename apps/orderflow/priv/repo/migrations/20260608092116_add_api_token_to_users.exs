defmodule Orderflow.Repo.Migrations.AddApiTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_token, :string
    end

    create unique_index(:users, [:api_token])
  end
end
