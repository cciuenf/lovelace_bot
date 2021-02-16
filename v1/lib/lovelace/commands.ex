defmodule Lovelace.Commands do
  @moduledoc """
  Define all bot's commands
  """

  use Lovelace.Router
  use Lovelace.Commander

  alias Lovelace.Helpers

  command "bemvindo" do
    Logger.log(:info, "Command /bemvindo")

    ~s(Seja bem vindo ao grupo de Ciência da Computação! )
    |> Kernel.<>(
      ~s|Leia as regras do grupo no pinado e visite nosso GitHub(https://github.com/cciuenf) |
    )
    |> Kernel.<>(~s(Digite /ajuda para ver mais comandos!))
    |> send_message()
  end

  command "monads" do
    Logger.log(:info, "Command /monads")

    send_message("Monads são apenas monoids dentro da categoria dos endofunctors.")
  end

  command ["desafios", "desafio"] do
    Logger.log(:info, "Command /desafios | /desafio")

    Helpers.get_args(update.message.text)
    |> Helpers.get_challenges()
    |> send_message()
  end

  command "ranking" do
    Logger.log(:info, "Command /ranking")

    Helpers.get_args(update.message.text)
    |> Helpers.get_ranking()
    |> send_message()
  end

  command "piada" do
    Logger.log(:info, "Command /piada")

    Helpers.get_args(update.message.text)
    |> Helpers.get_joke()
    |> send_message()
  end

  command "ajuda" do
    Logger.log(:info, "Command /ajuda")

    send_message(
      "Lista de comandos: /bemvindo, /monads, /ranking, /desafios, /ajuda, /piada, /xkcd /kick"
    )
  end

  command "xkcd" do
    Logger.log(:info, "Command /xkcd")

    Helpers.get_args(update.message.text)
    |> Helpers.get_xkcd()
    |> send_message()
  end

  command "kick" do
    # Get Bot details to get Bot id
    {:ok, %Nadia.Model.User{id: my_id}} = get_me()
    # Get Chat Member details for this chat to get Bot permissions
    {:ok, %Nadia.Model.ChatMember{status: my_status}} = get_chat_member(my_id)

    # Get Chat Member details to get User Permissions and check for admin / creator
    {:ok, %Nadia.Model.ChatMember{status: user_status}} = get_chat_member(update.message.from.id)
    # Validate if Chat Type 'private', create error kick not available.

    # If insufficient permission, send error to Chat Group.
    cond do
      update.message.chat.type == "private" ->
        Logger.log(:error, "Command cannot be run in private chats")
        {:error, message: "Cannot run /kick in private chats. Who you kinkin'?"}

      not Enum.member?(["administrator", "creator"], user_status) ->
        Logger.log(:error, "User does not have enough permissions to kick another user")
        {:error, message: "You do not have enough permission to /kick a user"}

      not Enum.member?(["administrator", "creator"], my_status) ->
        Logger.log(:error, "Bot does not have enough permissions to kick a user")
        {:error, message: "I do not have enough permission to /kick a user"}

      true ->
        :ok
    end
    |> case do
      {:error, message: message} ->
        send_message(message)

      :ok ->
        Helpers.get_mentioned_users(update.message.entities)
        |> Enum.map(fn user_id ->
          case kick_chat_member(user_id) do
            {:error, error} ->
              Logger.log(:error, error.reason)
              send_message("An error occurred while kicking the user\n" <> error.reason)

            _ ->
              Logger.log(:info, "Kicked User")
          end
        end)
    end
  end

  # just avoiding errors when no command is found
  message do
  end
end
