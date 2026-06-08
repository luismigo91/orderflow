defmodule OrderflowWeb.Plugs.RateLimiterTest do
  use OrderflowWeb.ConnCase

  alias OrderflowWeb.Plugs.RateLimiter

  describe "rate limiting" do
    test "allows requests within limit", %{conn: conn} do
      conn = RateLimiter.call(conn, [])
      assert conn.status != 429
    end

    test "blocks requests after limit exceeded", %{conn: conn} do
      # Simulate multiple requests
      conn =
        Enum.reduce(1..101, conn, fn _i, conn ->
          RateLimiter.call(conn, [])
        end)

      assert conn.status == 429
      assert conn.halted
    end
  end
end
