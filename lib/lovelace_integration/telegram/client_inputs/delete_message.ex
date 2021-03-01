defmodule LovelaceIntegration.Telegram.ClientInputs.DeleteMessage do
  @moduledoc """
  Represents a Telegram delete message structure
  """

  use LovelaceIntegration.Telegram.ClientInputs

  alias Ecto.Changeset

  embedded_schema do
    field :chat_id, :integer
    field :message_id, :integer
  end

  @impl true
  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([:chat_id, :message_id])
  end
end
