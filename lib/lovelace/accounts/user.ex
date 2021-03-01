defmodule Lovelace.Accounts.User do
  @moduledoc """
  User entity
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :full_name, :string
    field :is_professor?, :boolean, default: false
    field :telegram_id, :integer
    field :telegram_username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:full_name, :telegram_username, :telegram_id, :is_professor?])
    |> validate_required([:full_name, :telegram_username, :telegram_id, :is_professor?])
  end
end
