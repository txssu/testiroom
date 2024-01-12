defmodule Testiroom.Repo.Migrations.CreateStartedEvents do
  use Ecto.Migration

  def change do
    create table(:started_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false

      add :attempt_id, references(:attempts, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:started_events, [:test_id])
    create index(:started_events, [:attempt_id])
  end
end
