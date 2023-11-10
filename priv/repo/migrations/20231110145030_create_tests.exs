defmodule Testiroom.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
