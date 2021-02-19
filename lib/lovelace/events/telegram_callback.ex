defmodule Lovelace.Events.TelegramCallback do
  @moduledoc """
  Models a telegram callback
  """

  alias LovelaceIntegration.Telegram.Callback

  @behaviour Lovelace.Events.Event

  @impl true
  def topic(_ \\ nil), do: "lovelace:integration:telegram_callback"

  @impl true
  def cast(%Callback{} = cb), do: {:ok, cb}

  def cast(params) do
    params
    |> Callback.cast()
    |> case do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      changeset ->
        {:error, changeset}
    end
  end
end
