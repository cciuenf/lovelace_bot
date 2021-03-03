defmodule Lovelace.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :full_name, :string
      add :telegram_username, :string
      add :telegram_id, :integer
      add :role, :string, default: "student"

      timestamps()
    end
  end
end
