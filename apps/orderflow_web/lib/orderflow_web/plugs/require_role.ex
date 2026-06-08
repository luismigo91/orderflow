defmodule OrderflowWeb.Plugs.RequireRole do
  @moduledoc """
  Ensures the user has the required role. Redirects if not.
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(role), do: role

  def call(conn, role) do
    user = conn.assigns[:current_user]

    if user && user.role == role do
      conn
    else
      conn
      |> put_flash(:error, "No tienes permiso para acceder a esta página.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
