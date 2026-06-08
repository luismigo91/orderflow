defmodule Orderflow.ShiftsFixtures do
  @moduledoc """
  This module defines test helpers for creating shifts.
  """

  alias Orderflow.Shifts

  def shift_fixture(user_id, attrs \\ %{}) do
    {:ok, shift} =
      Shifts.create_shift(
        Enum.into(attrs, %{
          user_id: user_id,
          date: Date.utc_today(),
          start_time: ~T[09:00:00],
          end_time: ~T[17:00:00],
          role: "server",
          status: :scheduled
        })
      )

    shift
  end
end
