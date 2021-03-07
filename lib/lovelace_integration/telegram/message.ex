defmodule LovelaceIntegration.Telegram.Message do
  @moduledoc """
  Representation of a message
  """
  use Ecto.Schema

  alias Ecto.Changeset

  @primary_key_opts {:id, :integer, autogenerate: false}

  @type t() :: %__MODULE__{
          message_id: integer(),
          chat_id: integer(),
          text: String.t(),
          user_id: integer(),
          from: map(),
          reply_to_message: map(),
          new_chat_member: map()
        }

  embedded_schema do
    field :message_id, :integer
    field :chat_id, :integer
    field :chat_type, :string
    field :text, :string
    field :user_id, :integer

    embeds_one :from, From, primary_key: @primary_key_opts do
      field :username, :string
      field :first_name, :string
      field :last_name, :string
    end

    embeds_one :new_chat_member, NewChartMember, primary_key: @primary_key_opts do
      field :is_bot, :boolean
      field :username, :string
    end

    embeds_one :reply_to_message, ReplyToMessage, primary_key: @primary_key_opts do
      field :chat_id, :integer
      field :message_id, :integer
      field :text, :string
      embeds_one :from, From
    end
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [:text, :message_id, :chat_id])
    |> Changeset.validate_required([:text, :message_id])
    |> put_chat_id()
    |> put_chat_type()
    |> put_user_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
    |> Changeset.cast_embed(:reply_to_message, with: &reply_to_message_changeset/2)
    |> Changeset.cast_embed(:new_chat_member, with: &new_chat_member_changeset/2)
  end

  defp new_chat_member_changeset(schema, params),
    do: Changeset.cast(schema, params, [:is_bot, :username, :id])

  defp reply_to_message_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:text, :message_id, :chat_id, :id])
    |> Changeset.validate_required([:text, :message_id])
    |> put_chat_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
  end

  defp from_changeset(schema, params),
    do: Changeset.cast(schema, params, [:username, :id, :last_name, :first_name])

  defp put_chat_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :chat_id,
      Changeset.get_change(changeset, :chat_id, params["chat"]["id"])
    )
  end

  defp put_chat_type(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :chat_type,
      Changeset.get_change(changeset, :chat_type, params["chat"]["type"])
    )
  end

  defp put_user_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :user_id,
      Changeset.get_change(changeset, :user_id, params["new_chat_member"]["id"])
    )
  end
end
