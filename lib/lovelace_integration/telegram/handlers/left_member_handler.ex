defmodule LovelaceIntegration.Telegram.Handlers.LeftMemberHandler do
  @moduledoc """
  Logs messages for the banned user
  """

  require Logger

  alias LovelaceIntegration.Telegram.{Client, Message}

  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{left_chat_member: lm} = msg) do
    user_reference = lm.username || lm.first_name

    config_ban_time = Application.get_env(:lovelace, :bot_config)[:ban_duration]

    %{
      chat_id: msg.chat_id,
      reply_to_message_id: msg.message_id,
      text:
        "O usuário #{user_reference} foi banide por #{config_ban_time}min pois não cumpriu o captcha a tempo!"
    }
    |> Client.send_message()
  end
end
