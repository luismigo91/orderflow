defmodule Orderflow.Repo.Migrations.CreateGiftCards do
  use Ecto.Migration

  def change do
    create table(:gift_cards) do
      add :code, :string, null: false
      add :balance, :decimal, null: false
      add :initial_amount, :decimal, null: false
      add :purchaser_id, references(:users, on_delete: :nilify_all)
      add :recipient_email, :string
      add :status, :string, default: "active", null: false
      add :expires_at, :utc_datetime
      add :redeemed_at, :utc_datetime
      add :message, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:gift_cards, [:code])
    create index(:gift_cards, [:status])
    create index(:gift_cards, [:purchaser_id])
  end
end
