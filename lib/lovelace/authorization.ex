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

  def can?(query, action) when is_list(query) and is_atom(action) do
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

  def can?(%User{} = user, action) when is_atom(action), do: user.roles |> can?(action)

  def can?(roles, action) when is_atom(action) do
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

  defp subset?(values, set), do: Enum.any?(values, fn x -> x in set end)

  defp is_admin?(roles), do: "admin" in roles
  defp is_student?(roles), do: "student" in roles
  defp is_professor?(roles), do: "professor" in roles
end
