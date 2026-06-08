defmodule Orderflow.ShiftsTest do
  use Orderflow.DataCase

  alias Orderflow.Shifts
  alias Orderflow.ShiftsFixtures
  alias Orderflow.AccountsFixtures

  describe "shifts" do
    test "create_shift/1 with valid data creates a shift" do
      user = AccountsFixtures.user_fixture()

      assert {:ok, shift} =
               Shifts.create_shift(%{
                 user_id: user.id,
                 date: Date.utc_today(),
                 start_time: ~T[09:00:00],
                 end_time: ~T[17:00:00],
                 role: "chef"
               })

      assert shift.role == "chef"
      assert shift.user_id == user.id
    end

    test "list_shifts_for_user/1 returns user shifts" do
      user = AccountsFixtures.user_fixture()
      shift = ShiftsFixtures.shift_fixture(user.id)
      assert shift.id in Enum.map(Shifts.list_shifts_for_user(user.id), & &1.id)
    end
  end
end
