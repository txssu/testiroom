defmodule Testiroom.Exams.StudentSelectedOption do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.TaskOption

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "student_selected_options" do
    belongs_to :student_answer, StudentAnswer
    belongs_to :task_option, TaskOption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student_selected_option, attrs) do
    student_selected_option
    |> cast(attrs, [:task_option_id])
    |> validate_required([:task_option_id])
  end
end
