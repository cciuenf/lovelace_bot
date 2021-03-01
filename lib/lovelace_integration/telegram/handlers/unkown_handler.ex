defmodule LovelaceIntegration.Telegram.Handlers.UnkownHandler do
  @moduledoc """
  Says that this command is unkown
  """

  alias LovelaceIntegration.Telegram.{Client, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{chat_id: c_id, message_id: m_id}) do
    %{
      chat_id: c_id,
      reply_to_message_id: m_id,
      text: "Eu não conheço esse comando... Talvez executar /ajuda possa ajudar!"
    }
    |> Client.send_message()
  end
end
