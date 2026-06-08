defmodule OrderflowWeb.Plugs.RateLimiter do
  @moduledoc """
  Rate limiting plug using ETS for API endpoints.
  Limits: 100 requests per minute per IP/API token.
  """
  import Plug.Conn

  @limit 100
  # 1 minute in ms
  @window 60_000
  @table :rate_limiter

  def init(opts), do: opts

  def call(conn, _opts) do
    ensure_table()
    key = rate_limit_key(conn)
    now = System.monotonic_time(:millisecond)

    case check_rate(key, now) do
      :ok ->
        conn

      :limit_exceeded ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(429, Jason.encode!(%{error: "Rate limit exceeded. Try again in a minute."}))
        |> halt()
    end
  end

  defp rate_limit_key(conn) do
    # Use API token if available, otherwise IP
    token = conn.assigns[:current_user_token]
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    token || ip
  end

  defp ensure_table do
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [:named_table, :public, :set])

      _ ->
        :ok
    end
  end

  defp check_rate(key, now) do
    case :ets.lookup(@table, key) do
      [{^key, count, window_start}] when now - window_start < @window ->
        if count >= @limit do
          :limit_exceeded
        else
          :ets.update_counter(@table, key, {2, 1})
          :ok
        end

      _ ->
        :ets.insert(@table, {key, 1, now})
        :ok
    end
  end
end
