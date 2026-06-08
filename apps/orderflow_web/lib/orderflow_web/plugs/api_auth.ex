defmodule OrderflowWeb.Plugs.ApiAuth do
  @moduledoc """
  Authenticates API requests via Bearer token.
  """
  import Plug.Conn

  alias Orderflow.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_bearer_token(conn) do
      nil ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          401,
          Jason.encode!(%{error: %{code: "unauthorized", message: "Missing token"}})
        )
        |> halt()

      token ->
        case Accounts.get_user_by_api_token(token) do
          nil ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(
              401,
              Jason.encode!(%{error: %{code: "unauthorized", message: "Invalid token"}})
            )
            |> halt()

          user ->
            assign(conn, :current_user, user)
        end
    end
  end

  defp get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> String.trim(token)
      _ -> nil
    end
  end
end
