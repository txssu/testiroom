defmodule Testiroom.Repo.Migrations.CreateTestTaskStudentAnswerSelectedOptions do
  use Ecto.Migration

  def change do
    create table(:test_task_student_answer_selected_options, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :student_answer_id,
          references(:test_task_students_answers, on_delete: :delete_all, type: :binary_id),
          null: false

      add :task_option_id,
          references(:test_task_options, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:test_task_student_answer_selected_options, [:student_answer_id])
    create index(:test_task_student_answer_selected_options, [:task_option_id])
  end
end
