defmodule Testiroom.Exams.StudentAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.TestResult
  alias Testiroom.Exams.Task
  alias Testiroom.Exams.TaskOption
  alias Testiroom.Exams.StudentSelectedOption

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "students_answers" do
    field :text, :string

    belongs_to :task, Task
    belongs_to :test_result, TestResult

    has_many :selected_options, StudentSelectedOption
    many_to_many :selected_task_options, TaskOption, join_through: StudentSelectedOption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student_answer, attrs) do
    student_answer
    |> cast(attrs, [:text, :task_id])
    |> cast_assoc(:selected_options)
    |> validate_required([:task_id])
  end
end
