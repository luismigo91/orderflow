defmodule Orderflow.TablesTest do
  use Orderflow.DataCase

  alias Orderflow.Tables
  alias Orderflow.TablesFixtures

  describe "tables" do
    test "list_tables/0 returns all tables" do
      table = TablesFixtures.table_fixture()
      assert table.id in Enum.map(Tables.list_tables(), & &1.id)
    end

    test "create_table/1 with valid data creates a table" do
      assert {:ok, table} = Tables.create_table(%{number: "A1", capacity: 4, location: "Main"})
      assert table.number == "A1"
      assert table.capacity == 4
    end

    test "create_table/1 with invalid data returns error" do
      assert {:error, _changeset} = Tables.create_table(%{number: "", capacity: 0})
    end
  end

  describe "reservations" do
    test "create_reservation/1 creates a reservation" do
      table = TablesFixtures.table_fixture()
      datetime = DateTime.add(DateTime.utc_now(), 2, :hour)

      assert {:ok, reservation} =
               Tables.create_reservation(%{
                 table_id: table.id,
                 customer_name: "John Doe",
                 party_size: 2,
                 datetime: datetime
               })

      assert reservation.customer_name == "John Doe"
    end
  end
end
