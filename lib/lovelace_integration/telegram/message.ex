defmodule LovelaceIntegration.Telegram.Message do
  @moduledoc """
  Representation of a message
  """
  use Ecto.Schema

  alias Ecto.Changeset

  embedded_schema do
    field :message_id, :integer
    field :chat_id, :integer
    field :text, :string
    field :user_id, :integer
    field :is_bot, :boolean

    embeds_one :from, From do
      field :username, :string
    end

    embeds_one :reply_to_message, ReplyToMessage do
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
    |> put_user_id()
    |> put_is_bot()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
    |> Changeset.cast_embed(:reply_to_message, with: &reply_to_message_changeset/2)
  end

  defp reply_to_message_changeset(schema, params) do
    schema
    |> Changeset.cast(params, [:text, :message_id, :chat_id])
    |> Changeset.validate_required([:text, :message_id])
    |> put_chat_id()
    |> Changeset.cast_embed(:from, with: &from_changeset/2)
  end

  defp from_changeset(schema, params), do: Changeset.cast(schema, params, [:username])

  defp put_chat_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :chat_id,
      Changeset.get_change(changeset, :chat_id, params["chat"]["id"])
    )
  end

  defp put_user_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :user_id,
      Changeset.get_change(changeset, :user_id, params["new_chat_member"]["id"])
    )
  end

  defp put_is_bot(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :is_bot,
      Changeset.get_change(changeset, :is_bot, params["new_chat_member"]["is_bot"])
    )
  end
end
