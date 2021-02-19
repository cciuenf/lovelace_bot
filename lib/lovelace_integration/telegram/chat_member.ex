defmodule LovelaceIntegration.Telegram.ChatMember do
  @moduledoc """
  Representation of a chat member
  """

  use Ecto.Schema

  alias Ecto.Changeset

  embedded_schema do
    field :user_id, :integer
    field :username, :string
    field :status, :string
    field :is_member, :boolean
  end

  def cast(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [:status, :is_member])
    |> Changeset.validate_required([:status, :is_member])
    |> put_user_id()
    |> put_username()
  end

  defp put_user_id(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :user_id,
      Changeset.get_change(changeset, :user_id, params["user"]["id"])
    )
  end

  defp put_username(%Ecto.Changeset{params: params} = changeset) do
    Ecto.Changeset.put_change(
      changeset,
      :username,
      Changeset.get_change(changeset, :user_id, params["user"]["username"])
    )
  end
end
