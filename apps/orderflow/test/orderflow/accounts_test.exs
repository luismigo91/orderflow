defmodule Orderflow.AccountsTest do
  use Orderflow.DataCase

  alias Orderflow.Accounts
  alias Orderflow.Accounts.User

  describe "users" do
    @valid_attrs %{
      email: "test@example.com",
      password: "password123",
      name: "Test User",
      role: :admin
    }
    @invalid_attrs %{email: nil, password: nil, name: nil, role: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert [listed_user] = Accounts.list_users()
      assert listed_user.id == user.id
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      found = Accounts.get_user!(user.id)
      assert found.id == user.id
      assert found.email == user.email
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      found = Accounts.get_user(user.id)
      assert found.id == user.id
      assert found.email == user.email
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = user_fixture()
      found = Accounts.get_user_by_email(user.email)
      assert found.id == user.id
      assert found.email == user.email
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "test@example.com"
      assert user.name == "Test User"
      assert user.role == :admin
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with duplicate email returns error" do
      user_fixture()
      assert {:error, changeset} = Accounts.create_user(@valid_attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{name: "Updated Name"})
      assert user.name == "Updated Name"
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "register_user/1 creates a user with hashed password" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert user.password_hash != nil
      assert Bcrypt.verify_pass("password123", user.password_hash)
    end

    test "authenticate_user/2 with valid credentials returns user" do
      user = user_fixture()
      assert {:ok, authenticated_user} = Accounts.authenticate_user(user.email, "password123")
      assert authenticated_user.id == user.id
    end

    test "authenticate_user/2 with invalid credentials returns error" do
      user_fixture()

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("wrong@example.com", "password123")

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("test@example.com", "wrongpassword")
    end
  end

  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test@example.com",
        password: "password123",
        name: "Test User",
        role: :admin
      })
      |> Accounts.register_user()

    user
  end
end
