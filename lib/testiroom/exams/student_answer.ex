defmodule Testiroom.Exams.StudentAnswer do
  use Ecto.Schema

  alias Testiroom.Exams.Task
  alias Testiroom.Exams.StudentAnswer.SelectedOption

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_students_answers" do
    field :text, :string

    belongs_to :task, Task
    has_many :selected_options, SelectedOption, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end
end
