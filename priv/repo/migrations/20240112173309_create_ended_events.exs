defmodule Testiroom.Repo.Migrations.CreateEndedEvents do
  use Ecto.Migration

  def change do
    create table(:ended_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:ended_events, [:test_id])
    create index(:ended_events, [:user_id])
  end
end
