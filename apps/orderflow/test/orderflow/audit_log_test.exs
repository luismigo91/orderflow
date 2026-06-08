defmodule Orderflow.AuditLogTest do
  use Orderflow.DataCase

  alias Orderflow.AuditLog
  alias Orderflow.AuditLog.Entry
  alias Orderflow.Accounts

  describe "audit logging" do
    setup do
      {:ok, user} =
        Accounts.register_user(%{
          email: "audit@example.com",
          password: "password123",
          name: "Audit User",
          role: :customer
        })

      %{user: user}
    end

    test "log_action creates an entry", %{user: user} do
      assert {:ok, %Entry{}} =
               AuditLog.log_action(
                 user.id,
                 "create",
                 "product",
                 1,
                 %{name: "Test Product"}
               )
    end

    test "list_entries returns recent entries", %{user: user} do
      AuditLog.log_action(user.id, "create", "product", 1, %{})
      AuditLog.log_action(user.id, "update", "product", 1, %{})

      entries = AuditLog.list_entries()
      assert length(entries) == 2
    end

    test "entries_for_resource filters by resource", %{user: user} do
      AuditLog.log_action(user.id, "create", "product", 1, %{})
      AuditLog.log_action(user.id, "create", "order", 2, %{})

      entries = AuditLog.entries_for_resource("product", 1)
      assert length(entries) == 1
      assert hd(entries).resource_type == "product"
    end
  end
end
