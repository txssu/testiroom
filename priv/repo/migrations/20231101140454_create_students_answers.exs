defmodule Testiroom.Repo.Migrations.CreateStudentsAnswers do
  use Ecto.Migration

  def change do
    create table(:students_answers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :task_id, references(:tasks, on_delete: :delete_all, type: :binary_id), null: false
      add :test_result_id, references(:test_results, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:students_answers, [:task_id])
  end
end
