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

  defmodule From do
    @moduledoc """
    Represents a from message structure
    """

    use Ecto.Schema

    @primary_key {:id, :integer, autogenerate: false}
    embedded_schema do
      field :username, :string
      field :first_name, :string
      field :last_name, :string
    end
  end

  embedded_schema do
    field :callback_id, :integer
    field :user_id, :integer
    field :chat_id, :integer
    field :data, :string

    embeds_one :from, From

    embeds_one :message, Message do
      field :date, :integer
      field :message_id, :integer

      embeds_one :reply_to_message, ReplyToMessage do
        field :chat_id, :integer
        field :message_id, :integer

        embeds_one :from, From
      end
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
    |> Changeset.cast_embed(:message, with: &message_changeset/2)
  end

  defp from_changeset(schema, params) do
    if params["from"]["username"] do
      Changeset.cast(schema, params, [:first_name, :last_name, :username, :id])
    else
      Changeset.cast(schema, params, [:first_name, :last_name, :id])
    end
  end

  defp message_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:date, :message_id])
    |> Changeset.validate_required([:date, :message_id])
    |> Changeset.cast_embed(:reply_to_message, with: &reply_to_message_changeset/2)
  end

  defp reply_to_message_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:message_id, :chat_id])
    |> Changeset.validate_required([:message_id])
    |> put_chat_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
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
