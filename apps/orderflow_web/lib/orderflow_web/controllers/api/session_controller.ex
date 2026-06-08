defmodule OrderflowWeb.Api.SessionController do
  use OrderflowWeb, :controller

  alias Orderflow.Accounts

  action_fallback OrderflowWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, user} = Accounts.generate_api_token(user)
        render(conn, :create, token: user.api_token, user: user)

      {:error, :invalid_credentials} ->
        {:error, :unauthorized}
    end
  end

  def me(conn, _params) do
    user = conn.assigns.current_user
    render(conn, :me, user: user)
  end
end
