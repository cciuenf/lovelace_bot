defmodule LovelaceIntegration.Telegram.Callback do
  @moduledoc """
  Representation of a callback query
  """
  use Ecto.Schema

  alias Ecto.Changeset

  @type t() :: %__MODULE__{
          callback_id: integer(),
          user_id: integer(),
          from: map(),
          data: String.t()
        }

  embedded_schema do
    field :callback_id, :integer
    field :user_id, :integer
    field :data, :string

    embeds_one :from, From do
      field :first_name, :string
      field :username, :string
    end
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [:text, :message_id, :chat_id])
    |> Changeset.validate_required([:text, :message_id])
    |> put_user_id()
    |> put_callback_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
  end

  defp from_changeset(schema, params),
    do: Changeset.cast(schema, params, [:username, :first_name])

  defp put_user_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :user_id,
      Changeset.get_change(changeset, :user_id, params["from"]["id"])
    )
  end

  defp put_callback_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :callback_id,
      Changeset.get_change(changeset, :user_id, params["id"])
    )
  end
end
