defmodule Testiroom.Repo.Migrations.CreateMaybeCheatedEvents do
  use Ecto.Migration

  def change do
    create table(:maybe_cheated_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :process, :string
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false
      add :attempt_id, references(:attempts, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:maybe_cheated_events, [:test_id])
    create index(:maybe_cheated_events, [:attempt_id])
  end
end
