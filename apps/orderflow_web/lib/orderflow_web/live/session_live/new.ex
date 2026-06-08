defmodule OrderflowWeb.SessionLive.New do
  use OrderflowWeb, :live_view

  alias Orderflow.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Iniciar Sesión")}
  end

  @impl true
  def handle_event("login", %{"email" => email, "password" => password}, socket) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bienvenido, #{user.name}!")
         |> push_navigate(to: redirect_path(user))
         |> Phoenix.LiveView.Utils.put_session(:user_id, user.id)}

      {:error, :invalid_credentials} ->
        {:noreply, put_flash(socket, :error, "Email o contraseña incorrectos.")}
    end
  end

  defp redirect_path(%{role: :admin}), do: "/admin"
  defp redirect_path(%{role: :chef}), do: "/kitchen"
  defp redirect_path(%{role: :rider}), do: "/"
  defp redirect_path(%{role: :customer}), do: "/"
end
