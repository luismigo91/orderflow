defmodule Orderflow.InventoryTest do
  use Orderflow.DataCase

  alias Orderflow.Inventory
  alias Orderflow.Catalog

  describe "inventory alerts" do
    setup do
      {:ok, category} = Catalog.create_category(%{name: "Test Category", description: "Test"})

      {:ok, product} =
        Catalog.create_product(%{
          name: "Low Stock Product",
          description: "Test",
          price: "10.00",
          stock: 3,
          category_id: category.id
        })

      %{product: product}
    end

    test "check_stock_levels creates alerts for low stock", %{product: product} do
      low_stock_products = Inventory.check_stock_levels()
      assert length(low_stock_products) >= 1
      assert Enum.any?(low_stock_products, &(&1.id == product.id))

      # Verify alerts were created
      alerts = Inventory.list_unresolved_alerts()
      alert = Enum.find(alerts, &(&1.product.id == product.id))
      assert alert.current_stock == 3
      assert alert.threshold == 5
    end

    test "list_unresolved_alerts returns unresolved alerts" do
      Inventory.check_stock_levels()
      alerts = Inventory.list_unresolved_alerts()

      assert length(alerts) >= 1
    end

    test "resolve_alert marks alert as resolved" do
      Inventory.check_stock_levels()
      [alert | _] = Inventory.list_unresolved_alerts()

      assert {:ok, resolved} = Inventory.resolve_alert(alert.id)
      assert resolved.resolved == true

      assert Inventory.list_unresolved_alerts() == []
    end
  end
end
