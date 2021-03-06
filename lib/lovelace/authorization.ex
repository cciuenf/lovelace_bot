defmodule Lovelace.Accounts.Authorization do
  @moduledoc """
  Authorize and give permissions to each type of user
  """

  alias Lovelace.Accounts
  alias Lovelace.Accounts.User

  @student_permissions ~w(can_list_ranking can_list challenges can_ask_definition)a

  @admin_permissions @student_permissions ++
                       ~w(can_list_users can_ban_user can_restrict_user can_promote_user can_verify)a

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
      {:ok, %{role: role}} ->
        can?(role, action)

      {:error, :not_found} ->
        false
    end
  end

  def can?(%User{role: role}, action) when action in @professor_permissions,
    do: can?(role, action)

  def can?(:admin, action) when action in @admin_permissions, do: true
  def can?(:admin, _action), do: false

  def can?(:student, action) when action in @student_permissions, do: true
  def can?(:student, _action), do: false

  def can?(:professor, action) when action in @professor_permissions, do: true
  def can?(:professor, _action), do: false

  def can?(_, _), do: false

  @doc """
  Given a user check if it is a admin

  ## Examples

     iex> is_admin?(admin_user)
     true

     iex> is_admin?(user)
     false
  """
  def is_admin?(%User{role: :admin}), do: true
  def is_admin?(_), do: false

  @doc """
  Given a user check if it is a student

  ## Examples

     iex> is_student?(student_user)
     true

     iex> is_student?(user)
     false
  """
  def is_student?(%User{role: :student}), do: true
  def is_student?(_), do: false

  @doc """
  Given a user check if it is a professor

  ## Examples

     iex> is_professor?(professor_user)
     true

     iex> is_professor?(user)
     false
  """
  def is_professor?(%User{role: :professor}), do: true
  def is_professr?(_), do: false
end
