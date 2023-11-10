defmodule Testiroom.Repo.Migrations.CreateTestTasks do
  use Ecto.Migration

  def change do
    create table(:test_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question, :string, null: false
      add :type, :string, null: false
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:test_tasks, [:test_id])
  end
end
