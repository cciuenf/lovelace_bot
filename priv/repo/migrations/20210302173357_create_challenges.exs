defmodule Lovelace.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :link, :string
      add :description, :text

      timestamps()
    end
  end
end
