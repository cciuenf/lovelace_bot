defmodule LovelaceIntegration.Telegram.Handlers.RoleChangeHandler do
  @moduledoc """
  Changes a member role
  """

  alias Lovelace.Accounts

  alias LovelaceIntegration.Telegram.{Client, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  import Lovelace.Accounts.Authorization

  def handle(%Message{text: "/roleadd" <> " " <> username} = msg) do
    {:ok, requester} = Accounts.get_user_by(telegram_id: msg.from.id)
    {:ok, user_to_promote} = Accounts.get_user_by(username: username)

    if can?(requester, :can_promote_user) do
      cond do
        is_student?(user_to_promote) ->
          user_to_promote
          |> Accounts.update_user_role(role: :admin)

          member_promoted(msg, user_to_promote, :admin)

        is_admin?(user_to_promote) ->
          user_to_promote
          |> Accounts.update_user_role(role: :professor)

          member_promoted(msg, user_to_promote, :professor)

        true ->
          %{
            chat_id: msg.chat_id,
            text: "Este usuário já possui privilégios de professor. Não é possível promovê-lo!",
            reply_to_message_id: msg.message_id
          }
          |> Client.send_message()
      end
    else
      Client.unauthenticated(msg)
    end
  end

  def handle(%Message{text: "/roleremove" <> " " <> username} = msg) do
    {:ok, requester} = Accounts.get_user_by(telegram_id: msg.from.id)
    {:ok, user_to_restrict} = Accounts.get_user_by(username: username)

    if can?(requester, :can_restrict_user) do
      cond do
        is_professor?(user_to_restrict) ->
          user_to_restrict
          |> Accounts.update_user_role(role: :admin)

          member_restricted(msg, user_to_restrict, :admin)

        is_admin?(user_to_restrict) ->
          user_to_restrict
          |> Accounts.update_user_role(role: :student)

          member_restricted(msg, user_to_restrict, :student)

        true ->
          %{
            chat_id: msg.chat_id,
            text: "Este usuário só possui o papel de aluno, não é possível restringi-lo!",
            reply_to_message_id: msg.message_id
          }
          |> Client.send_message()
      end
    else
      Client.unauthenticated(msg)
    end
  end

  defp member_promoted(msg, member, role) do
    user_reference = if member.username, do: member.username, else: member.full_name

    %{
      chat_id: msg.chat_id,
      text: "O usuário #{user_reference} foi promovido para o papel de #{role}!",
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  defp member_restricted(msg, member, role) do
    user_reference = if member.username, do: member.username, else: member.full_name

    %{
      chat_id: msg.chat_id,
      text: "O usuário #{user_reference} foi restringido para o papel de #{role}!",
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end
end
