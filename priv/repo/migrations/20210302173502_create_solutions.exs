defmodule Lovelace.Repo.Migrations.CreateSolutions do
  use Ecto.Migration

  def change do
    create table(:solutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :link, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :challenge_id, references(:challenges, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:solutions, [:user_id])
    create index(:solutions, [:challenge_id])
  end
end
