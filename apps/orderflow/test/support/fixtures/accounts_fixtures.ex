defmodule Orderflow.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating accounts.
  """

  alias Orderflow.Accounts

  def user_fixture(_attrs \\ %{}) do
    {:ok, user} =
      Accounts.register_user(%{
        email: "user#{System.unique_integer()}@example.com",
        password: "password123",
        name: "Test User",
        role: :customer
      })

    user
  end
end
