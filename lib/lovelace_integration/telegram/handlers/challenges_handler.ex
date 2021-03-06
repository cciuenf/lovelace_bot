defmodule LovelaceIntegration.Telegram.Handlers.ChallengesHandler do
  @moduledoc """
  Extract and shows challenges and it's info
  """

  alias LovelaceIntegration.Telegram.{Client, Helpers, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{text: "/desafios"} = msg) do
    {:ok, text} =
      Helpers.get_args(msg.text)
      |> Helpers.get_challenges()

    %{
      text: text,
      parse_mode: "HTML",
      chat_id: msg.chat_id,
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  def handle(%Message{text: "/desafio" <> _} = msg) do
    Helpers.get_args(msg.text)
    |> Helpers.get_challenges()
    |> case do
      {:ok, text} ->
        %{
          text: text,
          parse_mode: "HTML",
          chat_id: msg.chat_id,
          reply_to_message_id: msg.message_id
        }
        |> Client.send_message()

      {:error, reason} ->
        %{
          text: reason,
          chat_id: msg.chat_id,
          reply_to_message_id: msg.message_id
        }
        |> Client.send_message()
    end
  end
end
