defmodule OrderflowWeb.Api.SessionJSON do
  def create(%{token: token, user: user}) do
    %{
      data: %{
        token: token,
        user: user_data(user)
      }
    }
  end

  def me(%{user: user}) do
    %{data: user_data(user)}
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role
    }
  end
end
