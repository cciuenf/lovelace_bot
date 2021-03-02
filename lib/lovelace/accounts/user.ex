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

  alias Lovelace.Fun.Solution

  schema "users" do
    field :full_name, :string
    field :telegram_id, :integer
    field :telegram_username, :string
    field :roles, {:array, :string}, default: ["student"]

    has_many :solutions, Solution

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

  defp roles_are_subset?(_, value, data, opts \\ [message: "is invalid"]) do
    if Enum.any?(value, fn x -> x in data end) do
      []
    else
      [{:roles, opts[:message]}]
    end
  end

  defp validate_inclusion_within(%Ecto.Changeset{} = changeset, field, data, opts \\ []) do
    changeset
    |> validate_change(field, &roles_are_subset?(&1, &2, data, opts))
  end

  def roles, do: @roles
end
