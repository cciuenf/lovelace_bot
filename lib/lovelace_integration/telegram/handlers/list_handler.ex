defmodule LovelaceIntegration.Telegram.Handlers.ListHandler do
  @moduledoc """
  List all registered students
  """

  alias LovelaceIntegration.Telegram.{Client, Helpers, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  alias Lovelace.Accounts
  alias Lovelace.Accounts.Authorization

  def handle(%Message{} = msg) when msg.chat_type == "private" do
    %{
      chat_id: msg.chat_id,
      text: "Não posso listar nenhum aluno fora de um grupo",
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  def handle(%Message{text: "/listar"} = msg) do
    {:ok, requester} = Accounts.get_user_by(telegram_id: msg.from.id)

    if Authorization.is_professor?(requester) do
      text = Helpers.extract_students()

      %{
        text: text,
        parse_mode: "HTML",
        chat_id: msg.chat_id,
        reply_to_message_id: msg.message_id
      }
      |> Client.send_message()
    else
      Client.unauthenticated(msg)
    end
  end
end
