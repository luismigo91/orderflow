defmodule Orderflow.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :rating, :integer, null: false
      add :comment, :text
      add :customer_name, :string, null: false
      add :order_id, references(:orders, on_delete: :nilify_all)
      add :product_id, references(:products, on_delete: :nilify_all)

      timestamps()
    end
  end
end
