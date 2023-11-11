defmodule Testiroom.Exams.StudentAttempt do
  use Ecto.Schema

  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test

  defstruct ~w[test variant variant_length current_index answers current_task current_answer]a

  @type t :: %__MODULE__{
          test: Test.t(),
          variant: %{integer() => Task.t()},
          variant_length: integer(),
          answers: %{integer() => StudentAnswer.t()},
          current_index: integer(),
          current_task: Task.t(),
          current_answer: StudentAnswer.t() | nil
        }

  def new(test) do
    variant = get_variant(test)

    %__MODULE__{
      test: test,
      variant: variant,
      variant_length: Enum.count(variant),
      answers: %{}
    }
    |> select_task(0)
  end

  def select_task(student_attempt = %__MODULE__{}, index) do
    student_attempt
    |> Map.put(:current_index, index)
    |> Map.put(:current_task, student_attempt.variant[index])
    |> Map.put(:current_answer, Map.get(student_attempt.answers, index))
  end

  def answer_task(student_attempt = %__MODULE__{}, answer) do
    student_attempt
    |> Map.update!(:answers, &Map.put(&1, student_attempt.current_index, answer))
    |> Map.put(:current_answer, answer)
  end

  defp get_variant(test) do
    test.tasks
    |> Stream.with_index()
    |> Enum.into(%{}, fn {task, index} -> {index, task} end)
  end
end
