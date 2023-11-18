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
    {variant, answers} = get_variant_and_answers(test)

    %__MODULE__{
      test: test,
      variant: variant,
      count: Enum.count(variant),
      answers: answers
    }
  end

  def get_task(%__MODULE__{variant: variant}, index) do
    Map.get(variant, index)
  end

  def get_answer(%__MODULE__{answers: answers}, index) do
    Map.get(answers, index)
  end

  def answer_task(%__MODULE__{} = student_attempt, task_index, answer) do
    Map.update!(student_attempt, :answers, &Map.put(&1, task_index, answer))
  end

  def done_status(%__MODULE__{} = student_attempt) do
    student_attempt.answers
    |> :maps.iterator(:ordered)
    |> :maps.to_list()
    |> Enum.map(fn {_index, answer} ->
      answer.text != nil or answer.selected_options != []
    end)
  end

  defp get_variant_and_answers(test) do
    variant =
      test.tasks
      |> Stream.with_index()
      |> Enum.into(%{}, fn {task, index} -> {index, task} end)

    answers =
      Enum.into(
        variant,
        %{},
        fn {index, task} -> {index, StudentAnswer.new(task: task)} end
      )
      |> IO.inspect()

    {variant, answers}
  end
end
