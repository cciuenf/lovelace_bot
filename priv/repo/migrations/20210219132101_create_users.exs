defmodule Lovelace.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :telegram_username, :string
      add :telegram_id, :integer
      add :is_professor?, :boolean, default: false, null: false

      timestamps()
    end

  end
end
