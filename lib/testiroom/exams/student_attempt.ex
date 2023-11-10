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
          current_answer: StudentAnswer.t()
        }
end
