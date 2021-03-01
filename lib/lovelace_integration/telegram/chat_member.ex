defmodule LovelaceIntegration.Telegram.ChatMember do
  @moduledoc """
  Representation of a chat member
  """

  use Ecto.Schema

  alias Ecto.Changeset

  @cast_fields [:status, :is_member?, :full_name, :username, :is_bot?, :user_id]

  embedded_schema do
    field :user_id, :integer
    field :username, :string
    field :status, :string
    field :is_member?, :boolean
    field :full_name, :string
    field :is_bot?, :boolean
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, @cast_fields)
    |> Changeset.validate_required([:status])
    |> put_user_id()
    |> put_is_member()
    |> put_username()
    |> put_user_name()
  end

  defp put_user_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :user_id,
      Changeset.get_change(changeset, :user_id, params["user"]["id"])
    )
  end

  defp put_is_member(%Ecto.Changeset{} = changeset) do
    status = Changeset.get_change(changeset, :status, nil)

    is_member? = if status == "member", do: true, else: false

    Ecto.Changeset.put_change(
      changeset,
      :is_member?,
      is_member?
    )
  end

  defp put_username(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :username,
      Changeset.get_change(changeset, :user_id, params["user"]["username"])
    )
  end

  defp put_user_name(%Ecto.Changeset{params: params} = changeset) do
    first_name = params["user"]["first_name"] || ""
    last_name = params["user"]["last_name"] || ""

    full_name = first_name <> last_name

    Ecto.Changeset.put_change(
      changeset,
      :full_name,
      full_name
    )
  end
end
