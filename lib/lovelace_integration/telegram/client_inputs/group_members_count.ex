defmodule LovelaceIntegration.Telegram.ClientInputs.GroupMembersCount do
  @moduledoc """
  Represents a Group members Count delete message structure
  """

  use LovelaceIntegration.Telegram.ClientInputs

  alias Ecto.Changeset

  embedded_schema do
    field :chat_id, :integer
  end

  @impl true
  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([:chat_id])
  end
end
