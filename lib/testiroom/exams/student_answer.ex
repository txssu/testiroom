defmodule Testiroom.Exams.StudentAnswer do
  use Ecto.Schema

  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Task.Option

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_students_answers" do
    field :text, :string

    belongs_to :task, Task

    many_to_many :selected_options, Option,
      join_through: "test_task_student_answer_selected_options",
      on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end
end
