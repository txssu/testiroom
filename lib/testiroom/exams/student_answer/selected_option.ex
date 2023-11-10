defmodule Testiroom.Exams.StudentAnswer.SelectedOption do
  use Ecto.Schema

  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Task.Option

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_student_answer_selected_options" do
    belongs_to :student_answer, StudentAnswer
    belongs_to :task_option, Option

    timestamps(type: :utc_datetime)
  end
end
