defmodule Orderflow.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :order_id, references(:orders, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nilify_all)
      add :nps_score, :integer
      add :food_rating, :integer
      add :service_rating, :integer
      add :speed_rating, :integer
      add :comments, :text
      add :tags, {:array, :string}, default: []
      add :would_recommend, :boolean

      timestamps(type: :utc_datetime)
    end

    create index(:feedback, [:order_id])
    create index(:feedback, [:user_id])
    create index(:feedback, [:nps_score])
  end
end
