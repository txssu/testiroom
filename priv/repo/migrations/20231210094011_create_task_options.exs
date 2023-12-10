defmodule Testiroom.Repo.Migrations.CreateTaskOptions do
  use Ecto.Migration

  def change do
    create table(:task_options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string, null: false
      add :is_correct, :boolean, null: false
      add :task_id, references(:tasks, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:task_options, [:task_id])
  end
end
