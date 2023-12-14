defmodule Testiroom.Repo.Migrations.CreateStudentAnswers do
  use Ecto.Migration

  def change do
    create table(:student_answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order, :integer, null: false
      add :text_input, :string
      add :attempt_id, references(:attempts, on_delete: :delete_all, type: :binary_id), null: false
      add :task_id, references(:tasks, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:student_answers, [:attempt_id])
    create index(:student_answers, [:task_id])

    create table(:students_selected_options, primary_key: false) do
      add :student_answer_id, references(:student_answers, on_delete: :delete_all, type: :binary_id), null: false
      add :option_id, references(:task_options, on_delete: :delete_all, type: :binary_id), null: false
    end

    create index(:students_selected_options, [:student_answer_id])
    create index(:students_selected_options, [:option_id])
  end
end
