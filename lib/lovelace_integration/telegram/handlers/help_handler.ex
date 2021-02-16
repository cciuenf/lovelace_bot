defmodule LovelaceIntegration.Telegram.Handlers.HelpHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias LovelaceIntegration.Telegram.{Client, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{chat_id: c_id, message_id: m_id}) do
    %{
      chat_id: c_id,
      reply_to_message_id: m_id,
      text: "Send /xxx"
    }
    |> Client.send_message()
  end
end
