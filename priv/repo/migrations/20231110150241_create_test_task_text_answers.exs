defmodule Testiroom.Repo.Migrations.CreateTestTaskTextAnswers do
  use Ecto.Migration

  def change do
    create table(:test_task_text_answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string, null: false
      add :task_id, references(:test_tasks, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:test_task_text_answers, [:task_id])
  end
end
