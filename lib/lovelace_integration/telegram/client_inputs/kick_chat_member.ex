defmodule LovelaceIntegration.Telegram.ClientInputs.KickChatMember do
  @moduledoc """
  Represents a Telegram restrict user structure
  """

  use LovelaceIntegration.Telegram.ClientInputs

  alias Ecto.Changeset

  embedded_schema do
    field :chat_id, :integer
    field :user_id, :integer
    field :until_date, :integer
  end

  @impl true
  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([:chat_id, :user_id, :until_date])
  end
end
