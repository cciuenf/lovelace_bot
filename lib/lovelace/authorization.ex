defmodule Lovelace.Accounts.Authorization do
  @moduledoc """
  Authorize and give permissions to each type of user
  """

  alias Lovelace.Accounts
  alias Lovelace.Accounts.User

  @roles User.roles()

  @student_permissions ~w(can_list_ranking can_list challenges can_ask_definition)a

  @admin_permissions @student_permissions ++
                       ~w(can_list_users can_ban_user can_restrict_user can_promote_user)a

  @professor_permissions @admin_permissions ++ ~w(can_send_notices)a

  @doc """
  Checks if a given user can execute a given action

  ## Examples

     iex> can?(user, action)
     true

     iex> can?(query, action)
     true

     iex> can?(user, action)
     false
  """
  def can?(query, action) when is_list(query) and action in @professor_permissions do
    case Accounts.get_user_by(query) do
      {:ok, %{roles: roles}} ->
        if subset?(roles, @roles) do
          roles |> can?(action)
        else
          false
        end

      {:error, :not_found} ->
        false
    end
  end

  def can?(%User{} = user, action) when action in @professor_permissions,
    do: user.roles |> can?(action)

  def can?(roles, action) when action in @professor_permissions do
    cond do
      is_professor?(roles) ->
        if action in @professor_permissions, do: true, else: false

      is_admin?(roles) ->
        if action in @admin_permissions, do: true, else: false

      is_student?(roles) ->
        if action in @student_permissions, do: true, else: false

      true ->
        if action in @student_permissions, do: true, else: false
    end
  end

  def can?(_, _), do: false

  @doc """
  Check if a fiven list is a subset of a major list

  ## Examples

     iex> subset?(["student"], @roles)
     true
  """
  def subset?(values, set), do: Enum.any?(values, fn x -> x in set end)

  @doc """
  Given some roles, check if it is a admin
  """
  def is_admin?(roles), do: "admin" in roles

  @doc """
  Given some roles, check if it is a student
  """
  def is_student?(roles), do: "student" in roles

  @doc """
  Givensome roles, check if it is a professor
  """
  def is_professor?(roles), do: "professor" in roles
end
