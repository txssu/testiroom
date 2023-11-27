defmodule Testiroom.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question, :string, null: false
      add :type, :string, null: false
      add :shuffle_options, :boolean, default: false, null: false
      add :score, :integer
      add :order, :integer, null: false
      add :test_id, references(:tests, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:test_id])
  end
end
