defmodule LovelaceIntegration.Telegram.Handlers.LeftMemberHandler do
  @moduledoc """
  Logs messages for the banned user
  """

  require Logger

  alias Lovelace.State
  alias LovelaceIntegration.Telegram.{Client, Message}

  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{left_chat_member: lm} = msg) do
    user_reference = lm.username || lm.first_name

    config_ban_time = Application.get_env(:lovelace, :bot_config)[:ban_duration]

    message_id = State.get(:message_id)

    %{
      chat_id: msg.chat_id,
      message_id: message_id
    }
    |> Client.delete_message()

    %{
      chat_id: msg.chat_id,
      reply_to_message_id: msg.message_id,
      text:
        "O usuário #{user_reference} foi banide por #{config_ban_time}min pois não cumpriu o captcha a tempo!"
    }
    |> Client.send_message()
  end
end
