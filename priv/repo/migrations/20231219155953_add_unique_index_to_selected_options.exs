defmodule Testiroom.Repo.Migrations.AddUniqueIndexToSelectedOptions do
  use Ecto.Migration

  def change do
    create unique_index(:students_selected_options, [:student_answer_id, :option_id])
  end
end
