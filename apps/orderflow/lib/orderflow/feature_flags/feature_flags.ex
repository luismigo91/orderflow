defmodule Orderflow.FeatureFlags do
  @moduledoc """
  Contexto de feature flags para toggles en runtime.
  """

  alias Orderflow.Repo
  alias Orderflow.FeatureFlags.FeatureFlag

  def enabled?(name) do
    case Repo.get_by(FeatureFlag, name: to_string(name)) do
      nil -> false
      flag -> flag.enabled
    end
  end

  def toggle(name) do
    flag = Repo.get_by(FeatureFlag, name: to_string(name))

    if flag do
      Repo.update!(Ecto.Changeset.change(flag, enabled: !flag.enabled))
    else
      {:ok, _flag} = create_feature_flag(%{name: to_string(name), enabled: true})
    end
  end

  def create_feature_flag(attrs \\ %{}) do
    %FeatureFlag{}
    |> FeatureFlag.changeset(attrs)
    |> Repo.insert()
  end

  def list_feature_flags do
    Repo.all(FeatureFlag)
  end
end
