defmodule Testiroom.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order, :integer, null: false
      add :type, :string, null: false
      add :question, :string, null: false
      add :media_path, :string
      add :shuffle_options, :boolean, default: false, null: false
      add :score, :integer, default: 1, null: false
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:test_id])
  end
end
