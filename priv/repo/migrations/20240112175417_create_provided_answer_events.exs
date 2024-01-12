defmodule Testiroom.Repo.Migrations.CreateProvidedAnswerEvents do
  use Ecto.Migration

  def change do
    create table(:provided_answer_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :student_answer_id,
          references(:student_answers, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:provided_answer_events, [:test_id])
    create index(:provided_answer_events, [:user_id])
    create index(:provided_answer_events, [:student_answer_id])
  end
end
