defmodule OrderflowWeb.FeatureTest do
  use OrderflowWeb.ConnCase

  alias Orderflow.Accounts
  alias Orderflow.Catalog
  alias Orderflow.Orders

  describe "Complete order flow" do
    test "admin creates order, chef cooks it, rider delivers it", %{conn: _conn} do
      # Create users
      admin = user_fixture(%{role: :admin})
      chef = user_fixture(%{role: :chef})
      rider = user_fixture(%{role: :rider})

      # Create product
      product = product_fixture()

      # Admin creates order
      attrs = %{
        "customer_name" => "Juan Pérez",
        "customer_phone" => "555-0123",
        "items" => [%{"product_id" => product.id, "quantity" => 2}]
      }

      {:ok, order} = Orders.create_order(attrs, admin.id)
      assert order.status == :pending
      assert order.total == Decimal.new("20.00")

      # Chef advances to confirmed
      {:ok, order} = Orders.advance_status(order, :confirmed, chef.email)
      assert order.status == :confirmed

      # Chef advances to cooking
      {:ok, order} = Orders.advance_status(order, :cooking, chef.email)
      assert order.status == :cooking

      # Stock should be decremented
      updated_product = Catalog.get_product!(product.id)
      assert updated_product.stock == 8

      # Chef advances to ready
      {:ok, order} = Orders.advance_status(order, :ready, chef.email)
      assert order.status == :ready

      # Rider is assigned
      {:ok, order} = Orders.assign_rider(order, rider.id)
      assert order.assigned_user_id == rider.id

      # Rider advances to delivering
      {:ok, order} = Orders.advance_status(order, :delivering, rider.email)
      assert order.status == :delivering

      # Rider delivers
      {:ok, order} = Orders.advance_status(order, :delivered, rider.email)
      assert order.status == :delivered

      # Check status logs
      logs = Orders.list_status_logs(order.id)
      assert length(logs) == 5

      # Verify order in database
      db_order = Orders.get_order_with_items!(order.id)
      assert db_order.status == :delivered
      assert db_order.assigned_user_id == rider.id
    end
  end

  describe "Order cancellation flow" do
    test "cancelling order restores stock", %{conn: _conn} do
      admin = user_fixture(%{role: :admin})
      chef = user_fixture(%{role: :chef})
      product = product_fixture(%{stock: 10})

      attrs = %{
        "customer_name" => "Juan Pérez",
        "customer_phone" => "555-0123",
        "items" => [%{"product_id" => product.id, "quantity" => 3}]
      }

      {:ok, order} = Orders.create_order(attrs, admin.id)
      {:ok, order} = Orders.advance_status(order, :confirmed, chef.email)
      {:ok, order} = Orders.advance_status(order, :cooking, chef.email)

      # Verify stock decreased
      product = Catalog.get_product!(product.id)
      assert product.stock == 7

      # Cancel order
      {:ok, order} = Orders.cancel_order(order, "Cliente canceló", admin.email)
      assert order.status == :cancelled

      # Stock should be restored
      product = Catalog.get_product!(product.id)
      assert product.stock == 10
    end
  end

  describe "Authentication flow" do
    test "admin can authenticate and access dashboard", %{conn: conn} do
      admin = user_fixture(%{role: :admin})

      # Login via API
      conn = post(conn, "/api/v1/sessions", %{email: admin.email, password: "password123"})
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      token = response["data"]["token"]

      # Access protected endpoint
      conn = build_conn()
      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      conn = get(conn, "/api/v1/me")

      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert response["data"]["email"] == admin.email
      assert response["data"]["role"] == "admin"
    end
  end

  describe "Catalog management" do
    test "products can be created, updated, and deactivated" do
      category = category_fixture()

      {:ok, product} =
        Catalog.create_product(%{
          name: "New Product",
          description: "Test",
          price: "15.00",
          stock: 20,
          active: true,
          category_id: category.id
        })

      assert product.name == "New Product"
      assert product.active == true

      # Update stock
      {:ok, product} = Catalog.update_product(product, %{stock: 15})
      assert product.stock == 15

      # Deactivate
      {:ok, product} = Catalog.update_product(product, %{active: false})
      assert product.active == false

      # Verify in list
      products = Catalog.list_products()
      assert product.id in Enum.map(products, & &1.id)
    end
  end

  defp user_fixture(attrs) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test#{System.unique_integer()}@example.com",
        password: "password123",
        name: "Test User",
        role: :admin
      })
      |> Accounts.register_user()

    user
  end

  defp category_fixture do
    case Catalog.list_categories() |> List.first() do
      nil ->
        {:ok, cat} =
          Catalog.create_category(%{name: "Test Category", description: "Test", sort_order: 1})

        cat

      cat ->
        cat
    end
  end

  defp product_fixture(attrs \\ %{}) do
    category = category_fixture()

    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "Test Product",
        description: "Test",
        price: "10.00",
        stock: 10,
        active: true,
        category_id: category.id
      })
      |> Catalog.create_product()

    product
  end
end
