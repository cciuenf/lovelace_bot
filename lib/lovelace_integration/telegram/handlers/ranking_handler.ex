defmodule LovelaceIntegration.Telegram.Handlers.RankingHandler do
  @moduledoc """
  Shows the complete or relative challenge's ranking
  """

  alias LovelaceIntegration.Telegram.{Client, Helpers, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{} = msg) do
    text =
      Helpers.get_args(msg.text)
      |> Helpers.get_ranking()

    %{
      text: text,
      parse_mode: "HTML",
      chat_id: msg.chat_id,
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end
end
