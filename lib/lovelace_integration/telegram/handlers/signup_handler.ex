defmodule LovelaceIntegration.Telegram.Handlers.SignupHandler do
  @moduledoc """
  Allows a user to register themself
  """

  alias LovelaceIntegration.Telegram.{Client, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  require Logger

  alias Lovelace.Accounts

  def handle(%Message{} = msg) when msg.chat_type == "private" do
    %{
      chat_id: msg.chat_id,
      text: "Infelizmente só posso te cadastrar dentro de um grupo!",
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  def handle(%Message{} = msg) do
    case Accounts.get_user_by(telegram_id: msg.from.id) do
      {:ok, user} ->
        user_reference = if user.username, do: user.username, else: user.full_name

        %{
          chat_id: msg.chat_id,
          text: "O usuário #{user_reference} já está cadastrado com o papél de #{user.role}!",
          reply_to_message_id: msg.message_id
        }
        |> Client.send_message()

      {:error, :not_found} ->
        first_name = msg.from.first_name || ""
        last_name = msg.from.last_name || ""

        full_name = first_name <> " " <> last_name

        username = msg.from.username || first_name

        %{
          telegram_id: msg.from.id,
          telegram_username: username,
          full_name: full_name
        }
        |> Accounts.create_student()
        |> user_registred(msg)
    end
  end

  defp user_registred({:ok, user}, msg) do
    text = ~s"""
    O usuário #{user.telegram_username} se registrou!

    Como você se registrou manualmente, seu papel foi configurado como "student"

    Caso seu papél (cargo) esteja errado, mencione um administrador ou professor para te promover!
    """

    %{
      text: text,
      chat_id: msg.chat_id,
      reply_to_message_id: msg.message_id
    }
    |> Client.send_message()
  end

  defp user_registred({:error, changeset} = error, msg) do
    Logger.error("Error inserting user with id #{msg.from.id}")
    Logger.error("Error => #{inspect(changeset)}")

    error
  end
end
