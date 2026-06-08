defmodule Orderflow.TablesFixtures do
  @moduledoc """
  This module defines test helpers for creating tables and reservations.
  """

  alias Orderflow.Tables

  def table_fixture(attrs \\ %{}) do
    {:ok, table} =
      Tables.create_table(
        Enum.into(attrs, %{
          number: "T#{System.unique_integer([:positive])}",
          capacity: 4,
          status: :free,
          location: "Main Floor",
          active: true
        })
      )

    table
  end

  def reservation_fixture(attrs \\ %{}) do
    table = table_fixture()

    {:ok, reservation} =
      Tables.create_reservation(
        Enum.into(attrs, %{
          table_id: table.id,
          customer_name: "Test Customer",
          customer_phone: "555-1234",
          party_size: 2,
          datetime: DateTime.add(DateTime.utc_now(), 2, :hour),
          status: :confirmed
        })
      )

    reservation
  end
end
