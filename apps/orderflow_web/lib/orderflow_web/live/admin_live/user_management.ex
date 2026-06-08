defmodule OrderflowWeb.AdminLive.UserManagement do
  use OrderflowWeb, :live_view

  alias Orderflow.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:users, users)
     |> assign(:page_title, "Gestión de Usuarios")}
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, updated_user} = Accounts.update_user(user, %{active: !user.active})

    users =
      Enum.map(socket.assigns.users, fn u ->
        if u.id == updated_user.id, do: updated_user, else: u
      end)

    {:noreply, assign(socket, :users, users)}
  end
end
