defmodule OrderflowWeb.Presence do
  @moduledoc """
  Phoenix Presence for tracking online users.
  """
  use Phoenix.Presence,
    otp_app: :orderflow_web,
    pubsub_server: Orderflow.PubSub
end
