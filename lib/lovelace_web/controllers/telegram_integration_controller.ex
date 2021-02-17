defmodule LovelaceWeb.TelegramIntegrationController do
  use LovelaceWeb, :controller

  require Logger

  alias LovelaceIntegration.Telegram

  # we only match messages that start with a /, so we don't waste computer
  # power for messages that don't matter
  def webhook(conn, %{"message" => %{"text" => "/" <> _} = params}) do
    IO.inspect(params)

    with {:ok, message} <- Telegram.build_message(params),
         :ok <- Telegram.enqueue_processing!(message) do
      Logger.info("Message enqueued for later processing")
      send_resp(conn, 204, "")
    else
      err ->
        Logger.error("Failed handling telegram webhook with #{inspect(err)}, answering 204")

        send_resp(conn, 204, "")
    end
  end

  def webhook(conn, params),
    do:
      (
        IO.inspect(params)
        send_resp(conn, 204, "")
      )
end
