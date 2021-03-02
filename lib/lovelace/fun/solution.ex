defmodule Lovelace.Fun.Solution do
  @moduledoc """
  Challenges's solutions entity
  """

  import Ecto.Changeset

  alias Lovelace.Accounts.User
  alias Lovelace.Fun.Challenge

  @exposed_fields ~w(link)a

  @simple_sortings ~w(link)a

  @simple_filters ~w(user_id challenge_id link)a

  use Lovelace.Schema, expose: true, query: true

  schema "solutions" do
    field :link, :string

    belongs_to :user, User
    belongs_to :challenge, Challenge

    timestamps()
  end

  @doc false
  def changeset(solution, attrs) do
    solution
    |> cast(attrs, [:link, :user_id, :challenge_id])
    |> validate_required([:link, :user_id, :challenge_id])
  end
end
