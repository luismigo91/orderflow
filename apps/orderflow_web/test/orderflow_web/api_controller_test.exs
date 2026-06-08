defmodule OrderflowWeb.ApiControllerTest do
  use OrderflowWeb.ConnCase

  alias Orderflow.Accounts
  alias Orderflow.Catalog

  describe "API Authentication" do
    test "POST /api/v1/sessions returns token", %{conn: conn} do
      user = user_fixture()

      conn = post(conn, "/api/v1/sessions", %{email: user.email, password: "password123"})
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["data"]["token"]
      assert response["data"]["user"]["email"] == user.email
    end

    test "POST /api/v1/sessions with invalid credentials returns 401", %{conn: conn} do
      conn = post(conn, "/api/v1/sessions", %{email: "wrong@example.com", password: "wrong"})
      assert json_response(conn, 401)
    end
  end

  describe "API Orders" do
    setup %{conn: conn} do
      user = user_fixture()
      {:ok, user} = Accounts.generate_api_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{user.api_token}")
      {:ok, conn: conn, user: user}
    end

    test "GET /api/v1/orders returns list", %{conn: conn} do
      conn = get(conn, "/api/v1/orders")
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert is_list(response["data"])
    end

    test "GET /api/v1/orders/:id returns order", %{conn: conn, user: user} do
      order = order_fixture(user.id)
      conn = get(conn, "/api/v1/orders/#{order.id}")
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["data"]["id"] == order.id
    end

    test "POST /api/v1/orders creates order", %{conn: conn, user: _user} do
      product = product_fixture()

      conn =
        post(conn, "/api/v1/orders", %{
          "order" => %{
            "customer_name" => "Juan API",
            "customer_phone" => "555-9999",
            "items" => [%{"product_id" => product.id, "quantity" => 2}]
          }
        })

      assert json_response(conn, 201)
      response = json_response(conn, 201)
      assert response["data"]["customer_name"] == "Juan API"
    end

    test "PATCH /api/v1/orders/:id/status updates status", %{conn: conn, user: user} do
      order = order_fixture(user.id)

      conn =
        patch(conn, "/api/v1/orders/#{order.id}/status", %{
          "status" => "confirmed",
          "reason" => nil
        })

      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["data"]["status"] == "confirmed"
    end
  end

  describe "API Products" do
    setup %{conn: conn} do
      user = user_fixture()
      {:ok, user} = Accounts.generate_api_token(user)
      conn = put_req_header(conn, "authorization", "Bearer #{user.api_token}")
      {:ok, conn: conn}
    end

    test "GET /api/v1/products returns list", %{conn: conn} do
      conn = get(conn, "/api/v1/products")
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert is_list(response["data"])
    end

    test "GET /api/v1/products/:id returns product", %{conn: conn} do
      product = product_fixture()
      conn = get(conn, "/api/v1/products/#{product.id}")
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["data"]["id"] == product.id
    end
  end

  describe "API Authentication Required" do
    test "GET /api/v1/me without token returns 401", %{conn: conn} do
      conn = get(conn, "/api/v1/me")
      assert json_response(conn, 401)
    end

    test "GET /api/v1/orders without token returns 401", %{conn: conn} do
      conn = get(conn, "/api/v1/orders")
      assert json_response(conn, 401)
    end
  end

  defp user_fixture do
    {:ok, user} =
      %{
        email: "test#{System.unique_integer()}@example.com",
        password: "password123",
        name: "Test User",
        role: :admin
      }
      |> Accounts.register_user()

    user
  end

  defp order_fixture(user_id) do
    product = product_fixture()

    attrs = %{
      "customer_name" => "Juan Pérez",
      "customer_phone" => "555-0123",
      "items" => [%{"product_id" => product.id, "quantity" => 1}]
    }

    {:ok, order} = Orderflow.Orders.create_order(attrs, user_id)
    order
  end

  defp product_fixture do
    category =
      case Catalog.list_categories() |> List.first() do
        nil ->
          {:ok, cat} =
            Catalog.create_category(%{name: "Test Category", description: "Test", sort_order: 1})

          cat

        cat ->
          cat
      end

    {:ok, product} =
      Catalog.create_product(%{
        name: "Test Product",
        description: "Test",
        price: "10.00",
        stock: 10,
        active: true,
        category_id: category.id
      })

    product
  end
end
