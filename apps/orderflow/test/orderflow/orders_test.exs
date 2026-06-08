defmodule Orderflow.OrdersTest do
  use Orderflow.DataCase

  alias Orderflow.Orders
  alias Orderflow.Orders.Order
  alias Orderflow.Orders.OrderFSM
  alias Orderflow.Catalog
  alias Orderflow.Accounts

  describe "orders" do
    @valid_order_attrs %{
      "customer_name" => "Juan Pérez",
      "customer_phone" => "555-0123",
      "notes" => "Sin cebolla"
    }

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert [listed_order] = Orders.list_orders()
      assert listed_order.id == order.id
    end

    test "list_orders_by_status/1 returns orders by status" do
      order = order_fixture()
      assert [listed_order] = Orders.list_orders_by_status(:pending)
      assert listed_order.id == order.id
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      found = Orders.get_order!(order.id)
      assert found.id == order.id
    end

    test "get_order_with_items!/1 returns order with preloaded items" do
      order = order_fixture()
      found = Orders.get_order_with_items!(order.id)
      assert found.id == order.id
      assert is_list(found.order_items)
    end

    test "create_order/2 with valid data creates an order" do
      user = user_fixture()
      product = product_fixture()

      attrs =
        Map.put(@valid_order_attrs, "items", [%{"product_id" => product.id, "quantity" => 2}])

      assert {:ok, %Order{} = order} = Orders.create_order(attrs, user.id)
      assert order.customer_name == "Juan Pérez"
      assert order.status == :pending
      assert order.total != nil
    end

    test "create_order/2 without items creates empty order" do
      user = user_fixture()
      assert {:ok, %Order{} = order} = Orders.create_order(@valid_order_attrs, user.id)
      assert order.total == Decimal.new("0.00")
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Orders.update_order(order, %{"customer_name" => "Updated"})
      assert order.customer_name == "Updated"
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns an order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end

  describe "advance_status/4" do
    test "advances status through valid transitions" do
      order = order_fixture()
      user = user_fixture()

      assert {:ok, order} = Orders.advance_status(order, :confirmed, user.email)
      assert order.status == :confirmed

      assert {:ok, order} = Orders.advance_status(order, :cooking, user.email)
      assert order.status == :cooking

      assert {:ok, order} = Orders.advance_status(order, :ready, user.email)
      assert order.status == :ready

      assert {:ok, order} = Orders.advance_status(order, :delivering, user.email)
      assert order.status == :delivering

      assert {:ok, order} = Orders.advance_status(order, :delivered, user.email)
      assert order.status == :delivered
    end

    test "invalid transition returns error" do
      order = order_fixture()
      user = user_fixture()

      assert {:error, :invalid_transition, _} =
               Orders.advance_status(order, :delivered, user.email)
    end

    test "cancel_order/3 cancels an order" do
      order = order_fixture()
      user = user_fixture()

      assert {:ok, order} = Orders.cancel_order(order, "Cliente canceló", user.email)
      assert order.status == :cancelled
    end

    test "advance_status/4 logs status change" do
      order = order_fixture()
      user = user_fixture()

      Orders.advance_status(order, :confirmed, user.email)
      logs = Orders.list_status_logs(order.id)
      assert length(logs) == 1
      assert hd(logs).to_status == :confirmed
    end
  end

  describe "OrderFSM" do
    test "allowed_transitions/1 returns correct transitions" do
      assert :confirmed in OrderFSM.allowed_transitions(:pending)
      assert :cancelled in OrderFSM.allowed_transitions(:pending)
      assert :cooking in OrderFSM.allowed_transitions(:confirmed)
      assert :ready in OrderFSM.allowed_transitions(:cooking)
      assert :delivering in OrderFSM.allowed_transitions(:ready)
      assert :delivered in OrderFSM.allowed_transitions(:delivering)
      assert OrderFSM.allowed_transitions(:delivered) == []
      assert OrderFSM.allowed_transitions(:cancelled) == []
    end

    test "transition_allowed?/2 validates transitions" do
      assert OrderFSM.transition_allowed?(:pending, :confirmed)
      assert OrderFSM.transition_allowed?(:confirmed, :cooking)
      refute OrderFSM.transition_allowed?(:pending, :delivered)
      refute OrderFSM.transition_allowed?(:delivered, :pending)
    end

    test "validate_transition!/2 returns ok for valid transitions" do
      assert :ok = OrderFSM.validate_transition!(:pending, :confirmed)
    end

    test "validate_transition!/2 returns error for invalid transitions" do
      assert {:error, :invalid_transition, _} =
               OrderFSM.validate_transition!(:pending, :delivered)
    end
  end

  describe "assign_rider/2" do
    test "assigns rider to order" do
      order = order_fixture()
      rider = user_fixture(%{email: "rider2@test.com", role: :rider})

      assert {:ok, order} = Orders.assign_rider(order, rider.id)
      assert order.assigned_user_id == rider.id
    end
  end

  describe "stock management" do
    test "decrements stock when transitioning to cooking" do
      user = user_fixture()
      product = product_fixture(%{stock: 10})

      attrs =
        Map.put(@valid_order_attrs, "items", [%{"product_id" => product.id, "quantity" => 2}])

      {:ok, order} = Orders.create_order(attrs, user.id)

      {:ok, order} = Orders.advance_status(order, :confirmed, user.email)
      {:ok, _order} = Orders.advance_status(order, :cooking, user.email)

      updated_product = Catalog.get_product!(product.id)
      assert updated_product.stock == 8
    end

    test "restores stock when cancelling from cooking" do
      user = user_fixture()
      product = product_fixture(%{stock: 10})

      attrs =
        Map.put(@valid_order_attrs, "items", [%{"product_id" => product.id, "quantity" => 2}])

      {:ok, order} = Orders.create_order(attrs, user.id)

      {:ok, order} = Orders.advance_status(order, :confirmed, user.email)
      {:ok, order} = Orders.advance_status(order, :cooking, user.email)
      {:ok, _order} = Orders.cancel_order(order, "Test", user.email)

      updated_product = Catalog.get_product!(product.id)
      assert updated_product.stock == 10
    end
  end

  defp user_fixture(attrs \\ %{}) do
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

  defp product_fixture(attrs \\ %{}) do
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

  defp order_fixture(attrs \\ %{}) do
    user = user_fixture()
    product = product_fixture()

    order_attrs =
      attrs
      |> Enum.into(%{
        "customer_name" => "Juan",
        "customer_phone" => "555-0000",
        "items" => [%{"product_id" => product.id, "quantity" => 1}]
      })

    {:ok, order} = Orders.create_order(order_attrs, user.id)
    order
  end
end
