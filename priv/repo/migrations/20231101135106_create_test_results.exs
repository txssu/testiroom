defmodule Testiroom.Repo.Migrations.CreateTestResults do
  use Ecto.Migration

  def change do
    create table(:test_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :test_id, references(:tests, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:test_results, [:test_id])
  end
end
