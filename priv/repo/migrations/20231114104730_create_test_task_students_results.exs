defmodule Testiroom.Repo.Migrations.CreateTestTaskStudentsResults do
  use Ecto.Migration

  def change do
    create table(:test_task_students_results, primary_key: false) do
      add :id, :binary_id, primary_key: true

      timestamps(type: :utc_datetime)
    end

    alter table(:test_task_students_answers) do
      add :attempt_result_id,
          references(:test_task_students_results, on_delete: :delete_all, type: :binary_id),
          null: false
    end

    create index(:test_task_students_answers, [:attempt_result_id])
  end
end
