defmodule Lovelace.Fun.Challenge do
  @moduledoc """
  Challenge entity
  """

  import Ecto.Changeset

  alias Lovelace.Fun.Solution

  @exposed_fields ~w(link description solutions)a

  @simple_filters ~w(link)a

  @simple_sortings ~w(link)a

  use Lovelace.Schema, expose: true, query: true

  schema "challenges" do
    field :description, :string
    field :link, :string

    has_many :solutions, Solution

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:link, :description])
    |> validate_required([:link, :description])
  end
end
