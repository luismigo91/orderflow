defmodule ElixirTestWeb.Api.HealthController do
  use ElixirTestWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      status: "ok",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: "0.1.0"
    })
  end
end
