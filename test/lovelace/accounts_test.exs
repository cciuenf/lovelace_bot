defmodule Lovelace.AccountsTest do
  use Lovelace.DataCase, async: true

  alias Lovelace.Accounts

  import Lovelace.Factory

  describe "users" do
    alias Lovelace.Accounts.User

    @roles User.roles()

    @valid_attrs %{
      full_name: "some first_name",
      telegram_id: 42,
      telegram_username: "some telegram_username"
    }
    @update_attrs %{
      full_name: "some updated first_name",
      telegram_id: 43,
      telegram_username: "some updated telegram_username"
    }
    @invalid_attrs %{
      full_name: nil,
      telegram_id: nil,
      telegram_username: nil
    }

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "list_students/0 returns all students" do
      student = insert(:student)
      assert Accounts.list_students() == [student]
    end

    test "list_professors/0 retuns all professors" do
      professor = insert(:professor)
      assert Accounts.list_professors() == [professor]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.full_name == "some first_name"
      assert user.telegram_id == 42
      assert user.telegram_username == "some telegram_username"
    end

    test "create_student/1 with valid data creates a student" do
      assert {:ok, %User{} = student} = Accounts.create_student(@valid_attrs)
      assert student.full_name == "some first_name"
      assert student.telegram_id == 42
      assert student.telegram_username == "some telegram_username"
      assert student.role == :student
    end

    test "create_professor/1 with valid data creates a professor" do
      assert {:ok, %User{} = professor} = Accounts.create_professor(@valid_attrs)
      assert professor.full_name == "some first_name"
      assert professor.telegram_id == 42
      assert professor.telegram_username == "some telegram_username"
      assert professor.role == :professor
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_professor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_professor(@invalid_attrs)
    end

    test "create_student/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_student(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.full_name == "some updated first_name"
      assert user.telegram_id == 43
      assert user.telegram_username == "some updated telegram_username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user_role/2 with valid data updates the user role" do
      user = insert(:user)
      role = Enum.random(@roles)
      assert {:ok, %User{} = user} = Accounts.update_user_role(user, role: role)
      assert user.role == role
    end

    test "update_user_role/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_role(user, role: "invalid_role")
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
