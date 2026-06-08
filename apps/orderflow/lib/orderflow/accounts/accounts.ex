defmodule Orderflow.Accounts do
  @moduledoc """
  Contexto de gestión de usuarios y autenticación.
  """

  import Ecto.Query, warn: false
  alias Orderflow.Repo
  alias Orderflow.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def list_active_users do
    User
    |> where([u], u.active == true)
    |> Repo.all()
  end

  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    case get_user_by_email(email) do
      nil ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def generate_api_token(%User{} = user) do
    token = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

    user
    |> Ecto.Changeset.change(api_token: token)
    |> Repo.update()
  end

  def get_user_by_api_token(token) do
    Repo.get_by(User, api_token: token)
  end
end
