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

  def get_correct_as_list(result) do
    Enum.map(result.answers, &StudentAnswer.correct?/1)
  end

  def get_grade(ratio) do
    cond do
      ratio >= 0.80 -> "Отлично"
      ratio >= 0.60 -> "Хорошо"
      ratio >= 0.40 -> "Удовлетворительно"
      true -> "Неудовлетворительно"
    end
  end
end
