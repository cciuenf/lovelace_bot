defmodule Lovelace.Accounts.User do
  @moduledoc """
  User entity
  """

  @fields ~w(full_name telegram_id telegram_username)a

  @required_fields @fields

  @exposed_fields @fields ++ [:roles]

  @simple_filters @fields ++ [:roles]

  @simple_sortings ~w(telegram_id)a

  @roles ~w(student professor admin)

  use Lovelace.Schema, expose: true, query: true

  import Ecto.Changeset

  schema "users" do
    field :full_name, :string
    field :telegram_id, :integer
    field :telegram_username, :string
    field :roles, {:array, :string}, default: ["student"]

    timestamps()
  end

  @doc """
  Main changeset, to create a User
  """
  def user_changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end

  @doc """
  Changeset to set any role to any user
  """
  def role_changeset(user, attrs) do
    user
    |> cast(attrs, [:roles])
    |> validate_inclusion_within(:roles, @roles)
  end

  @doc """
  Creates a User with professor role
  """
  def professor_changeset(user, attrs) do
    user
    |> user_changeset(attrs)
    |> change(%{roles: ["professor", "admin"]})
  end

  @doc """
  Creates a User with student role
  """
  def student_changeset(user, attrs) do
    user
    |> user_changeset(attrs)
    |> change(%{roles: ["student"]})
  end

  defp validate_inclusion_within(%Ecto.Changeset{} = changeset, field, data, opts \\ []) do
    changeset
    |> validate_change(field, fn _, value ->
      if Enum.any?(value, fn x -> x in data end) do
        []
      else
        msg = if is_binary(opts[:message]), do: opts[:message], else: "is invalid"

        [{field, msg}]
      end
    end)
  end

  def roles, do: @roles
end
