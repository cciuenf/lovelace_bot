defmodule LovelaceIntegration.Telegram.ClientInputs.GetChatMember do
  @moduledoc """
  Represents a Telegram get chat member structure
  """

  use LovelaceIntegration.Telegram.ClientInputs

  alias Ecto.Changeset

  embedded_schema do
    field :chat_id, :integer
    field :user_id, :integer
  end

  @impl true
  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([:chat_id, :user_id])
  end
end
