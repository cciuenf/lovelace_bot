defmodule LovelaceIntegration.Telegram.Handlers.VerifyHandler do
  @moduledoc """
  Checks the group health, show group info and more
  """

  alias LovelaceIntegration.Telegram.{Client, Helpers, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  alias Lovelace.Accounts
  alias Lovelace.Accounts.Authorization

  def handle(%Message{} = msg) when msg.chat_type == "private" do
    %{
      chat_id: msg.chat_id,
      text: "Olá! Obrigado por perguntar! Eu vou muito bem, e você?",
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  def handle(%Message{text: "/verificar"} = msg) do
    {:ok, requester} = Accounts.get_user_by(telegram_id: msg.from.id)

    if Authorization.can?(requester, :can_verify) do
      {:ok, %{body: members_count}} = %{chat_id: msg.chat_id} |> Client.get_group_members_count()

      text = Helpers.extract_group_info(members_count)

      %{
        text: text,
        parse_mode: "HTML",
        chat_id: msg.chat_id,
        reply_to_message_id: msg.message_id
      }
      |> Client.send_message()
    else
      Client.unauthenticated(msg)
    end
  end
end
