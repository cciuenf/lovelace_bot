defmodule LovelaceWeb.TelegramIntegrationController do
  use LovelaceWeb, :controller

  require Logger

  alias LovelaceIntegration.Telegram

  def webhook(conn, %{"callback_query" => _} = params) do
    with {:ok, callback_query} <- Telegram.build_callback(params["callback_query"]),
         :ok <- Telegram.enqueue_processing!(callback_query) do
      Logger.info("Callback enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error(
          "Failed handling telegram callback query with #{inspect(err)}, answering 204"
        )

        send_resp(conn, 204, "")
    end
  end

  # we only match messages that start with a /, so we don't waste computer
  # power for messages that don't matter
  def webhook(conn, %{"message" => %{"text" => "/" <> _} = params}) do
    with {:ok, message} <- Telegram.build_message(params),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Command Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Failed handling telegram command with #{inspect(err)}, answering 204")

        send_resp(conn, 204, "")
    end
  end

  def webhook(conn, %{"message" => %{"left_chat_member" => %{"id" => id}} = params}) do
    params =
      params
      |> Map.put("text", "left_user")

    with true <- Application.get_env(:lovelace, :user_id) == id,
         true <- Application.get_env(:lovelace, :timer_ref) |> is_nil(),
         {:ok, message} <- Telegram.build_message(params),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Left User Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Failed handling telegram command with #{inspect(err)}, answering 204")

        send_resp(conn, 204, "")
    end
  end

  def webhook(conn, %{"message" => %{"new_chat_member" => _} = params}) do
    params =
      params
      |> Map.put("text", "new_user")

    with {:ok, message} <- Telegram.build_message(params),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("New User Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error(
          "Failed handling telegram new_chat_member with #{inspect(err)}, answering 204"
        )

        send_resp(conn, 204, "")
    end
  end

  def webhook(conn, _params), do: send_resp(conn, 204, "")
end
