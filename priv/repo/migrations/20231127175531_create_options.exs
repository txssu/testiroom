defmodule Testiroom.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :is_correct, :boolean, default: false, null: false
      add :task_id, references(:tasks, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:options, [:task_id])
  end
end
