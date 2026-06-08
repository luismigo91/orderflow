defmodule OrderflowWeb.SessionController do
  use OrderflowWeb, :controller

  alias Orderflow.Accounts

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Bienvenido, #{user.name}!")
        |> redirect(to: redirect_path(user))

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Email o contraseña incorrectos.")
        |> redirect(to: "/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Sesión cerrada.")
    |> redirect(to: "/")
  end

  defp redirect_path(%{role: :admin}), do: "/admin"
  defp redirect_path(%{role: :chef}), do: "/kitchen"
  defp redirect_path(%{role: :rider}), do: "/"
  defp redirect_path(%{role: :customer}), do: "/"
end
