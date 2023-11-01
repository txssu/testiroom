defmodule Testiroom.Repo.Migrations.CreateStudentSelectedOptions do
  use Ecto.Migration

  def change do
    create table(:student_selected_options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :student_answer_id, references(:students_answers, on_delete: :nothing, type: :binary_id)
      add :task_option_id, references(:task_options, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:student_selected_options, [:student_answer_id])
    create index(:student_selected_options, [:task_option_id])
  end
end
