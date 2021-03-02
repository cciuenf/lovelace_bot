defmodule Lovelace.FunTest do
  use Lovelace.DataCase, async: true

  alias Lovelace.Fun

  import Lovelace.Factory

  describe "challenges" do
    alias Lovelace.Fun.Challenge

    @valid_attrs %{description: "some description", link: "some link"}
    @update_attrs %{description: "some updated description", link: "some updated link"}
    @invalid_attrs %{description: nil, link: nil}

    test "list_challenges/0 returns all challenges" do
      challenge = insert(:challenge)
      assert Fun.list_challenges() == [challenge]
    end

    test "get_challenge!/1 returns the challenge with given id" do
      challenge = insert(:challenge)
      assert Fun.get_challenge!(challenge.id) == challenge
    end

    test "create_challenge/1 with valid data creates a challenge" do
      assert {:ok, %Challenge{} = challenge} = Fun.create_challenge(@valid_attrs)
      assert challenge.description == "some description"
      assert challenge.link == "some link"
    end

    test "create_challenge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fun.create_challenge(@invalid_attrs)
    end

    test "update_challenge/2 with valid data updates the challenge" do
      challenge = insert(:challenge)
      assert {:ok, %Challenge{} = challenge} = Fun.update_challenge(challenge, @update_attrs)
      assert challenge.description == "some updated description"
      assert challenge.link == "some updated link"
    end

    test "update_challenge/2 with invalid data returns error changeset" do
      challenge = insert(:challenge)
      assert {:error, %Ecto.Changeset{}} = Fun.update_challenge(challenge, @invalid_attrs)
      assert challenge == Fun.get_challenge!(challenge.id)
    end

    test "delete_challenge/1 deletes the challenge" do
      challenge = insert(:challenge)
      assert {:ok, %Challenge{}} = Fun.delete_challenge(challenge)
      assert_raise Ecto.NoResultsError, fn -> Fun.get_challenge!(challenge.id) end
    end

    test "change_challenge/1 returns a challenge changeset" do
      challenge = insert(:challenge)
      assert %Ecto.Changeset{} = Fun.change_challenge(challenge)
    end
  end

  describe "solutions" do
    alias Lovelace.Fun.Solution

    @valid_attrs %{link: "some link"}
    @update_attrs %{link: "some updated link"}
    @invalid_attrs %{link: nil}

    def solution_fixture(attrs \\ %{}) do
      %{id: user_id} = insert(:user)
      %{id: challenge_id} = insert(:challenge)

      attrs =
        attrs
        |> Map.merge(%{user_id: user_id, challenge_id: challenge_id})

      {:ok, solution} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Fun.create_solution()

      solution
    end

    test "list_solutions/0 returns all solutions" do
      solution = solution_fixture()
      assert Fun.list_solutions() == [solution]
    end

    test "list_challenge_solutions/1 returns all challenge solutions" do
      challenge = insert(:challenge)
      solution = insert(:solution, challenge: challenge)
      assert Fun.list_challenge_solutions(challenge) == [solution]
    end

    test "list_user_solutions/1 returns all user solutions" do
      user = insert(:user)
      solution = insert(:solution, user: user)
      assert Fun.list_user_solutions(user) == [solution]
    end

    test "get_solution!/1 returns the solution with given id" do
      solution = solution_fixture()
      assert Fun.get_solution!(solution.id) == solution
    end

    test "create_solution/1 with valid data creates a solution" do
      %{id: user_id} = insert(:user)
      %{id: challenge_id} = insert(:challenge)

      valid_attrs = @valid_attrs |> Map.merge(%{user_id: user_id, challenge_id: challenge_id})

      assert {:ok, %Solution{} = solution} = Fun.create_solution(valid_attrs)
      assert solution.link == "some link"
    end

    test "create_solution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fun.create_solution(@invalid_attrs)
    end

    test "update_solution/2 with valid data updates the solution" do
      solution = solution_fixture()
      assert {:ok, %Solution{} = solution} = Fun.update_solution(solution, @update_attrs)
      assert solution.link == "some updated link"
    end

    test "update_solution/2 with invalid data returns error changeset" do
      solution = solution_fixture()
      assert {:error, %Ecto.Changeset{}} = Fun.update_solution(solution, @invalid_attrs)
      assert solution == Fun.get_solution!(solution.id)
    end

    test "delete_solution/1 deletes the solution" do
      solution = solution_fixture()
      assert {:ok, %Solution{}} = Fun.delete_solution(solution)
      assert_raise Ecto.NoResultsError, fn -> Fun.get_solution!(solution.id) end
    end

    test "change_solution/1 returns a solution changeset" do
      solution = solution_fixture()
      assert %Ecto.Changeset{} = Fun.change_solution(solution)
    end
  end
end
