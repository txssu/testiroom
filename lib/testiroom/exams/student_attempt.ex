defmodule Testiroom.Exams.StudentAttempt do
  use Ecto.Schema

  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test

  defstruct ~w[test variant answers count]a

  @type t :: %__MODULE__{
          test: Test.t(),
          variant: %{integer() => Task.t()},
          answers: %{integer() => StudentAnswer.t()},
          count: integer()
        }

  def new(test) do
    variant = get_variant(test)

    %__MODULE__{
      test: test,
      variant: variant,
      count: Enum.count(variant),
      answers: %{}
    }
  end

  def get_task(%__MODULE__{variant: variant}, index) do
    Map.get(variant, index)
  end

  def get_answer(%__MODULE__{answers: answers}, index) do
    Map.get(answers, index)
  end

  def answer_task(%__MODULE__{} = student_attempt, task_index, answer) do
    task = get_task(student_attempt, task_index)
    answer = StudentAnswer.put_task(answer, task)
    Map.update!(student_attempt, :answers, &Map.put(&1, task_index, answer))
  end

  defp get_variant(test) do
    test.tasks
    |> Stream.with_index()
    |> Enum.into(%{}, fn {task, index} -> {index, task} end)
  end
end
