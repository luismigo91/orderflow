defmodule OrderflowWeb.Api.TableControllerTest do
  use OrderflowWeb.ConnCase

  alias Orderflow.Accounts

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, user} = Accounts.generate_api_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{user.api_token}")
    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "lists all tables", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/tables")
      assert json_response(conn, 200)["data"]
    end
  end

  describe "create table" do
    test "creates table with valid data", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/tables", table: %{number: "B1", capacity: 6})
      assert json_response(conn, 201)["data"]["number"] == "B1"
    end
  end

  defp user_fixture do
    {:ok, user} =
      Accounts.register_user(%{
        email: "test#{System.unique_integer()}@example.com",
        password: "password123",
        name: "Test User",
        role: :admin
      })

    user
  end
end
