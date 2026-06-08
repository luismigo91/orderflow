defmodule OrderflowWeb.ChatLive.Index do
  use OrderflowWeb, :live_view

  alias OrderflowWeb.Presence

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "chat:general")

      # Track user presence
      {:ok, _} =
        Presence.track(socket.id, "chat:general", %{
          user_id: socket.assigns.current_user.id,
          name: socket.assigns.current_user.name,
          role: socket.assigns.current_user.role,
          online_at: System.system_time(:second)
        })

      # Get initial online users
      Phoenix.PubSub.subscribe(Orderflow.PubSub, "presence:chat:general")
    end

    online_users = get_online_users()

    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:online_users, online_users)
     |> assign(:page_title, "Chat")}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    user = socket.assigns.current_user

    msg = %{
      id: System.unique_integer([:positive]),
      user: user.name,
      role: user.role,
      text: message,
      timestamp: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(Orderflow.PubSub, "chat:general", %{
      event: "new_message",
      message: msg
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new_message", message: msg}, socket) do
    messages = [msg | socket.assigns.messages] |> Enum.take(50)
    {:noreply, assign(socket, :messages, messages)}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, assign(socket, :online_users, get_online_users())}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp get_online_users do
    Presence.list("chat:general")
    |> Enum.map(fn {_id, %{metas: [meta | _]}} -> meta end)
    |> Enum.uniq_by(& &1.user_id)
  end
end
