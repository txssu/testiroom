defmodule Testiroom.Exams.StudentAnswer do
  use Ecto.Schema

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_students_answers" do
    field :text, :string

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end
end
