defmodule Lovelace.Events.TelegramMessage do
  @moduledoc """
  Models a telegram message
  """

  alias LovelaceIntegration.Telegram.Message

  @behaviour Lovelace.Events.Event

  @impl true
  def topic(_ \\ nil), do: "lovelace:integration:telegram_message"

  @impl true
  def cast(%Message{} = msg), do: {:ok, msg}

  def cast(params) do
    params
    |> Message.cast()
    |> case do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
