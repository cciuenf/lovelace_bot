defmodule LovelaceIntegration.Telegram.Handlers.BanHandler do
  @moduledoc """
  Kicks and ban a user forever from a group
  """

  alias LovelaceIntegration.Telegram.{Client, Helpers, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Message{} = msg) when msg.chat_type == "private" do
    %{
      chat_id: msg.chat_id,
      text: "Parece que você está tentando banir alguém fora de um grupo...",
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  def handle(%Message{} = msg) do
    msg.text
    |> Helpers.get_args()
    |> String.split(" ")
    |> Helpers.parse_mentions(msg)
    |> Helpers.get_mentioned_users()
    |> Enum.map(fn
      {:ok, user, _mention} ->
        %{
          chat_id: msg.chat_id,
          user_id: user.telegram_id,
          until_date: Helpers.forever()
        }
        |> Client.ban_user()

      {:error, :not_found, mention} ->
        Client.dont_exist(msg, mention)
    end)
  end
end
