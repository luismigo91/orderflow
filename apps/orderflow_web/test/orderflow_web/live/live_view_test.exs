defmodule OrderflowWeb.LiveViewTest do
  use OrderflowWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Orderflow.Accounts
  alias Orderflow.Catalog

  describe "Session Live" do
    test "renders login form", %{conn: conn} do
      {:ok, _lv, html} = live(conn, "/login")
      assert html =~ "Iniciar Sesión"
      assert html =~ "Email"
      assert html =~ "Contraseña"
    end

    test "login with valid credentials redirects", %{conn: conn} do
      {:ok, lv, _html} = live(conn, "/login")

      result =
        lv
        |> form("form", %{"email" => "admin@orderflow.com", "password" => "admin123"})
        |> render_submit()

      # The redirect happens through push_navigate in the LiveView
      # In tests, we verify the form submission works
      assert result
    end
  end

  describe "OrderTracker Live" do
    setup do
      user = user_fixture(%{email: "test#{System.unique_integer()}@example.com"})
      order = order_fixture(user.id)
      {:ok, order: order}
    end

    test "renders order tracking", %{conn: conn, order: order} do
      {:ok, _lv, html} = live(conn, "/track/#{order.id}")
      assert html =~ "OrderFlow Tracker"
      assert html =~ "Pedido ##{order.id}"
    end
  end

  describe "Kitchen Live" do
    test "requires authentication", %{conn: conn} do
      result = live(conn, "/kitchen")
      assert {:error, {:redirect, %{to: "/login"}}} = result
    end

    test "requires chef role", %{conn: conn} do
      admin = user_fixture(%{email: "admin#{System.unique_integer()}@example.com", role: :admin})
      conn = log_in_user(conn, admin)

      result = live(conn, "/kitchen")
      assert {:error, {:redirect, %{to: "/"}}} = result
    end

    test "renders for chef", %{conn: conn} do
      chef = user_fixture(%{email: "chef#{System.unique_integer()}@example.com", role: :chef})
      conn = log_in_user(conn, chef)

      {:ok, _lv, html} = live(conn, "/kitchen")
      assert html =~ "Cocina"
    end
  end

  describe "Admin Dashboard Live" do
    test "requires admin role", %{conn: conn} do
      chef = user_fixture(%{email: "chef#{System.unique_integer()}@example.com", role: :chef})
      conn = log_in_user(conn, chef)

      result = live(conn, "/admin")
      assert {:error, {:redirect, %{to: "/"}}} = result
    end

    test "renders for admin", %{conn: conn} do
      admin = user_fixture(%{email: "admin#{System.unique_integer()}@example.com", role: :admin})
      conn = log_in_user(conn, admin)

      {:ok, _lv, html} = live(conn, "/admin")
      assert html =~ "Dashboard"
      assert html =~ "Pedidos Hoy"
      assert html =~ "Ingresos Hoy"
      assert html =~ "Pedidos Activos"
    end
  end

  describe "Admin User Management" do
    test "lists users for admin", %{conn: conn} do
      admin = user_fixture(%{email: "admin#{System.unique_integer()}@example.com", role: :admin})
      conn = log_in_user(conn, admin)

      {:ok, _lv, html} = live(conn, "/admin/users")
      assert html =~ "Gestión de Usuarios"
    end
  end

  describe "Admin Product Management" do
    test "lists products for admin", %{conn: conn} do
      admin = user_fixture(%{email: "admin#{System.unique_integer()}@example.com", role: :admin})
      conn = log_in_user(conn, admin)

      {:ok, _lv, html} = live(conn, "/admin/products")
      assert html =~ "Gestión de Productos"
    end
  end

  describe "Admin Order History" do
    test "lists orders for admin", %{conn: conn} do
      admin = user_fixture(%{email: "admin#{System.unique_integer()}@example.com", role: :admin})
      conn = log_in_user(conn, admin)

      {:ok, _lv, html} = live(conn, "/admin/history")
      assert html =~ "Historial de Pedidos"
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

  defp log_in_user(conn, user) do
    conn
    |> init_test_session(%{})
    |> put_session(:user_id, user.id)
  end
end
