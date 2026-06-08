defmodule Orderflow.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :name, :string
    field :role, Ecto.Enum, values: [:admin, :chef, :rider, :customer]
    field :phone, :string
    field :active, :boolean, default: true
    field :api_token, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :role, :phone, :active, :password])
    |> validate_required([:email, :name, :role, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "debe ser un email válido")
    |> validate_length(:password, min: 6, message: "debe tener al menos 6 caracteres")
    |> validate_inclusion(:role, [:admin, :chef, :rider, :customer])
    |> unique_constraint(:email)
    |> maybe_hash_password()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :role, :phone, :active])
    |> validate_required([:email, :name, :role])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "debe ser un email válido")
    |> validate_inclusion(:role, [:admin, :chef, :rider, :customer])
    |> unique_constraint(:email)
  end

  defp maybe_hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
