defmodule LovelaceIntegration.Telegram.Handlers.DefaultHandler do
  @moduledoc """
  Just logs the message since we can't handle it
  """

  require Logger

  alias LovelaceIntegration.Telegram.Message

  @behaviour LovelaceIntegration.Telegram.Handlers

  @impl true
  def handle(%Message{message_id: id}) do
    Logger.info("Received and ignored message #{id}")

    {:ok, nil}
  end
end
