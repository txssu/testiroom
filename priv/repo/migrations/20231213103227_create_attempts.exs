defmodule Testiroom.Repo.Migrations.CreateAttempts do
  use Ecto.Migration

  def change do
    create table(:attempts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ended_at, :timestamptz
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:attempts, [:user_id])
    create index(:attempts, [:test_id])
  end
end
