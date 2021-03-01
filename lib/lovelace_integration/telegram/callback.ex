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

  @cast_fields [:callback_id, :data, :user_id, :chat_id]

  embedded_schema do
    field :callback_id, :integer
    field :user_id, :integer
    field :chat_id, :integer
    field :data, :string

    embeds_one :from, From do
      field :username, :string
      field :first_name, :string
      field :last_name, :string
    end
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, @cast_fields)
    |> Changeset.validate_required([:data])
    |> put_chat_id()
    |> put_user_id()
    |> put_callback_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
  end

  defp from_changeset(schema, params) do
    if params["from"]["username"] do
      Changeset.cast(schema, params, [:first_name, :last_name, :username])
    else
      Changeset.cast(schema, params, [:first_name, :last_name])
    end
  end

  defp put_user_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :user_id,
      Changeset.get_change(changeset, :user_id, params["from"]["id"])
    )
  end

  defp put_chat_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :chat_id,
      Changeset.get_change(changeset, :chat_id, params["message"]["chat"]["id"])
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
