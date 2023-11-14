defmodule Testiroom.Exams.StudentAttemptResult do
  use Ecto.Schema

  alias Testiroom.Exams.StudentAnswer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_students_results" do
    has_many :answers, StudentAnswer, foreign_key: :attempt_result_id
    timestamps(type: :utc_datetime)
  end

  def new(answers) do
    %__MODULE__{answers: answers}
  end
end
