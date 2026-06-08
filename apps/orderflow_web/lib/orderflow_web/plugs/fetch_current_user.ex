defmodule OrderflowWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Fetches the current user from the session and assigns it to the connection.
  """
  import Plug.Conn

  alias Orderflow.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        assign(conn, :current_user, nil)

      user_id ->
        user = Accounts.get_user(user_id)
        assign(conn, :current_user, user)
    end
  end
end
