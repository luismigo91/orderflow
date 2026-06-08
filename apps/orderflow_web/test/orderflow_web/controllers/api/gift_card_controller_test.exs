defmodule OrderflowWeb.Api.GiftCardControllerTest do
  use OrderflowWeb.ConnCase

  alias Orderflow.Accounts

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, user} = Accounts.generate_api_token(user)
    conn = put_req_header(conn, "authorization", "Bearer #{user.api_token}")
    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "lists all gift cards", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/gift-cards")
      assert json_response(conn, 200)["data"]
    end
  end

  describe "create gift card" do
    test "creates gift card with valid data", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/gift-cards",
          gift_card: %{initial_amount: "100.00", recipient_email: "test@example.com"}
        )

      assert json_response(conn, 201)["data"]["balance"]
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
