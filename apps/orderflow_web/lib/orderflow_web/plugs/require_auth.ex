defmodule OrderflowWeb.Plugs.RequireAuth do
  @moduledoc """
  Ensures the user is authenticated. Redirects to login if not.
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Debes iniciar sesión para acceder a esta página.")
      |> redirect(to: "/login")
      |> halt()
    end
  end
end
