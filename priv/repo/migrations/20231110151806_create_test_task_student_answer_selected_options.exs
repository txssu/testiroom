defmodule Testiroom.Repo.Migrations.CreateTestTaskStudentAnswerSelectedOptions do
  use Ecto.Migration

  def change do
    create table(:test_task_student_answer_selected_options, primary_key: false) do
      add :student_answer_id,
          references(:test_task_students_answers, on_delete: :delete_all, type: :binary_id),
          null: false

      add :option_id,
          references(:test_task_options, on_delete: :delete_all, type: :binary_id),
          null: false
    end

    create index(:test_task_student_answer_selected_options, [:student_answer_id])
    create index(:test_task_student_answer_selected_options, [:option_id])
  end
end
