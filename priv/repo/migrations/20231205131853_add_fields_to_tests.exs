defmodule Testiroom.Repo.Migrations.AddFieldsToTests do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :description, :string

      add :starts_at, :utc_datetime
      add :ends_at, :utc_datetime
      add :duration_in_minutes, :integer

      add :show_results_for_student, :boolean, default: true, null: false
      add :show_score_for_student, :boolean, default: true, null: false
      add :show_grade_for_student, :boolean, default: true, null: false
      add :show_answers_for_student, :boolean, default: true, null: false
    end
  end
end
