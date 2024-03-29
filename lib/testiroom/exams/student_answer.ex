defmodule Testiroom.Exams.StudentAnswer do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Option
  alias Testiroom.Exams.Task

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "student_answers" do
    field :order, :integer
    field :text_input, :string

    belongs_to :attempt, Attempt
    belongs_to :task, Task

    many_to_many :selected_options, Option, join_through: "students_selected_options", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(student_answer, attrs) do
    student_answer
    |> cast(attrs, [:text_input])
    |> validate_required([])
  end

  @spec get_score(t) :: {score, max_score}
        when score: integer(), max_score: integer()
  def get_score(student_answer) do
    max = student_answer.task.score

    if correct?(student_answer) do
      {max, max}
    else
      {0, max}
    end
  end

  @spec correct?(t()) :: boolean()
  def correct?(student_answer) do
    task = student_answer.task

    case task.type do
      :text ->
        answers = for %{text: text} <- task.options, do: String.downcase(text)

        not is_nil(student_answer.text_input) and String.downcase(student_answer.text_input) in answers

      :single ->
        student_answer.selected_options
        |> Enum.map(& &1.is_correct)
        |> List.first(false)

      :multiple ->
        selected_options = student_answer.selected_options
        task_options = student_answer.task.options

        all_selected_correct?(selected_options) and
          exact_correct_count?(selected_options, task_options)
    end
  end

  @spec answer_given?(t()) :: boolean()
  def answer_given?(student_answer) do
    case student_answer.task.type do
      type when type in [:single, :multiple] -> student_answer.selected_options != []
      :text -> student_answer.text_input
    end
  end

  @spec all_selected_correct?([Option.t()]) :: boolean()
  defp all_selected_correct?(selected_options) do
    Enum.all?(selected_options, & &1.is_correct)
  end

  @spec exact_correct_count?([Option.t()], [Option.t()]) :: boolean()
  defp exact_correct_count?(selected_options, task_options) do
    Enum.count(selected_options) == Enum.count(task_options, & &1.is_correct)
  end
end
