defmodule Orderflow.AuditLog do
  @moduledoc """
  Context for audit logging of admin actions.
  """
  import Ecto.Query

  alias Orderflow.AuditLog.Entry
  alias Orderflow.Repo

  @doc """
  Log an action.
  """
  def log_action(user_id, action, resource_type, resource_id, metadata \\ %{}) do
    %Entry{}
    |> Entry.changeset(%{
      user_id: user_id,
      action: action,
      resource_type: resource_type,
      resource_id: to_string(resource_id),
      metadata: metadata,
      # Would be populated from conn
      ip_address: nil
    })
    |> Repo.insert()
  end

  @doc """
  List recent audit entries.
  """
  def list_entries(limit \\ 100) do
    Entry
    |> preload(:user)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Get entries for a specific resource.
  """
  def entries_for_resource(resource_type, resource_id) do
    Entry
    |> where([e], e.resource_type == ^resource_type and e.resource_id == ^to_string(resource_id))
    |> preload(:user)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
