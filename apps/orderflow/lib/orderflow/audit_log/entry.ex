defmodule Orderflow.AuditLog.Entry do
  @moduledoc """
  Schema for audit log entries.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "audit_log_entries" do
    field :action, :string
    field :resource_type, :string
    field :resource_id, :string
    field :metadata, :map, default: %{}
    field :ip_address, :string

    belongs_to :user, Orderflow.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:action, :resource_type, :resource_id, :metadata, :ip_address, :user_id])
    |> validate_required([:action, :resource_type, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
