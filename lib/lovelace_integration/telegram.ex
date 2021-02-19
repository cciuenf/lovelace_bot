defmodule LovelaceIntegration.Telegram do
  @moduledoc """
  Telegram message helpers
  """

  require Logger

  alias Lovelace.Events
  alias LovelaceIntegration.Telegram.Handlers
  alias LovelaceIntegration.Telegram.Message
  alias LovelaceIntegration.Telegram.ChatMember

  @doc """
  Builds a ChatMember struct from response
  """
  def build_chat_member(params) do
    params
    |> ChatMember.cast()
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Builds a message from a telegram message representation
  """
  def build_message(params) do
    params
    |> Message.cast()
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Processes a message with its handler
  """
  def process_message(%Message{} = msg) do
    {:ok, handler} = msg |> Handlers.get_handler()

    Logger.info("Processing message #{inspect(msg.message_id)} with handler #{inspect(handler)}")

    msg
    |> handler.handle()
  end

  @doc """
  Enqueues processing for a message
  Publishes it as an event in the pubsub
  """
  def enqueue_processing!(%Message{} = m) do
    Events.publish!(Events.TelegramMessage, m)
  end
end
