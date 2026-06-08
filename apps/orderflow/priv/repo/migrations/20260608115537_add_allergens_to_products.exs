defmodule Orderflow.Repo.Migrations.AddAllergensToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :allergens, {:array, :string}, default: []
      add :nutritional_info, :map, default: %{}
    end

    create index(:products, [:allergens], using: :gin)
  end
end
