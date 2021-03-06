defmodule LovelaceIntegration.Telegram.Handlers.BanHandler do
  @moduledoc """
  Kicks and ban a user forever from a group
  """

  alias Lovelace.Accounts
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
    |> Enum.filter(&(&1 =~ "@"))
    |> Helpers.get_mentioned_users_ids()
    |> Enum.map(fn
      {:ok, user} ->
        %{
          chat_id: msg.chat_id,
          user_id: user.telegram_id,
          until_date: Helpers.forever()
        }
        |> Client.ban_user()

      {:error, :not_found} ->
        %{
          chat_id: msg.chat_id,
          text: ~s(O usuário "#{username}" não foi encontrado...),
          reply_to_message_id: msg.message_id
        }
        |> Client.send_message()
    end)
  end
end
