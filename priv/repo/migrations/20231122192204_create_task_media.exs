defmodule Testiroom.Repo.Migrations.CreateTaskMedia do
  use Ecto.Migration

  def change do
    create table(:test_tasks_media, primary_key: false) do
      add :task_id,
          references(:test_tasks, on_delete: :delete_all, type: :binary_id),
          null: false

      add :media_id,
          references(:media, on_delete: :delete_all, type: :binary_id),
          null: false
    end

    create index(:test_tasks_media, [:task_id])
    create index(:test_tasks_media, [:media_id])
  end
end
