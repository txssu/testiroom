defmodule Testiroom.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :text, null: false
      add :description, :text
      add :starts_at, :naive_datetime
      add :ends_at, :naive_datetime
      add :duration_in_seconds, :integer
      add :show_correctness_for_student, :boolean, default: true, null: false
      add :show_score_for_student, :boolean, default: true, null: false
      add :show_grade_for_student, :boolean, default: true, null: false
      add :show_answer_for_student, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tests, [:user_id])
  end
end
