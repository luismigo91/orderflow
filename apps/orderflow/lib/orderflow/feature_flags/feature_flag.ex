defmodule Orderflow.FeatureFlags.FeatureFlag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feature_flags" do
    field :name, :string
    field :enabled, :boolean, default: false
    field :description, :string

    timestamps()
  end

  def changeset(flag, attrs) do
    flag
    |> cast(attrs, [:name, :enabled, :description])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
