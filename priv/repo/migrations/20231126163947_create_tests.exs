defmodule Testiroom.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :string
      add :starts_at, :utc_datetime
      add :ends_at, :utc_datetime
      add :duration, :time
      add :show_results, :boolean, default: true, null: false
      add :show_score, :boolean, default: true, null: false
      add :show_grade, :boolean, default: true, null: false
      add :show_answers, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
