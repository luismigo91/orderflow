defmodule Orderflow.ExportsTest do
  use Orderflow.DataCase

  alias Orderflow.Exports
  alias Orderflow.Orders
  alias Orderflow.Catalog
  alias Orderflow.Accounts

  describe "exports" do
    setup do
      {:ok, user} =
        Accounts.register_user(%{
          email: "export@example.com",
          password: "password123",
          name: "Export User",
          role: :customer
        })

      {:ok, category} = Catalog.create_category(%{name: "Food", description: "Test"})

      {:ok, product} =
        Catalog.create_product(%{
          name: "Test Product",
          description: "Test",
          price: "10.00",
          stock: 10,
          category_id: category.id
        })

      {:ok, order} =
        Orders.create_order(
          %{
            "customer_name" => "Test Customer",
            "customer_phone" => "555-0000",
            "items" => [%{"product_id" => product.id, "quantity" => 2}]
          },
          user.id
        )

      %{order: order}
    end

    test "export_orders_csv generates CSV", %{order: order} do
      csv = Exports.export_orders_csv([order])
      assert is_binary(csv)
      assert String.contains?(csv, "ID,Customer,Phone,Total,Status,Items,Created At")
      assert String.contains?(csv, "Test Customer")
      assert String.contains?(csv, "20.00")
    end

    test "generate_receipt_html creates HTML", %{order: order} do
      order = Orders.get_order_with_items!(order.id)
      html = Exports.generate_receipt_html(order)

      assert is_binary(html)
      assert String.contains?(html, "OrderFlow Receipt")
      assert String.contains?(html, "Test Customer")
      assert String.contains?(html, "Test Product")
    end
  end
end
