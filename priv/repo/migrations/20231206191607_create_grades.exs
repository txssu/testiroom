defmodule Testiroom.Repo.Migrations.CreateGrades do
  use Ecto.Migration

  def change do
    create table(:grades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :grade, :string, null: false
      add :from, :integer, null: false
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:grades, [:test_id])
  end
end
