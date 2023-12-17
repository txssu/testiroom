defmodule Testiroom.Exams.StudentAnswer do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Option
  alias Testiroom.Exams.Task

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
  def changeset(student_answer, attrs) do
    student_answer
    |> cast(attrs, [:text_input])
    |> validate_required([])
  end

  def get_score(student_answer) do
    max = student_answer.task.score

    if correct?(student_answer) do
      {max, max}
    else
      {0, max}
    end
  end

  def correct?(student_answer) do
    task = student_answer.task

    case task.type do
      :text ->
        answers = Enum.map(task.options, &Map.fetch!(&1, :text))
        student_answer.text_input in answers

      :single ->
        [selected_option] = student_answer.selected_options
        selected_option.is_correct

      :multiple ->
        selected_options = student_answer.selected_options
        task_options = student_answer.task.options

        all_selected_correct?(selected_options) and
          exact_correct_count?(selected_options, task_options)
    end
  end

  defp all_selected_correct?(selected_options) do
    Enum.all?(selected_options, & &1.is_correct)
  end

  defp exact_correct_count?(selected_options, task_options) do
    Enum.count(selected_options) == Enum.count(task_options, & &1.is_correct)
  end
end
