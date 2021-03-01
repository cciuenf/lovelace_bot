defmodule LovelaceIntegration.Telegram.Handlers.LeftMemberHandler do
  @moduledoc """
  Logs messages for the banned user
  """

  require Logger

  alias LovelaceIntegration.Telegram.{Client, Message}

  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{chat_id: c_id, message_id: m_id} = msg) do
    %{
      chat_id: c_id,
      reply_to_message_id: m_id,
      text: "O usuário #{msg.from.username} foi banide pois não cumpriu o captcha a tempo!"
    }
    |> Client.send_message()
  end
end
