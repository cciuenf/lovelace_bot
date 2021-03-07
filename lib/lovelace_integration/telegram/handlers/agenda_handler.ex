defmodule LovelaceIntegration.Telegram.Handlers.AgendaHandler do
  @moduledoc """
  Returns all next events of CC course
  """

  alias LovelaceIntegration.Telegram.{Client, Helpers, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{} = msg) do
    text = Helpers.extract_agenda()

    %{
      text: text,
      parse_mode: "HTML",
      chat_id: msg.chat_id,
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end
end
