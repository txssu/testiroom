defmodule Testiroom.Repo.Migrations.CreateMedia do
  use Ecto.Migration

  def change do
    create table(:media, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :path, :string

      timestamps(type: :utc_datetime)
    end
  end
end
