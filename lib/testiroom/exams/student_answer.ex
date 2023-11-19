defmodule Testiroom.Exams.StudentAnswer do
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.StudentAttemptResult
  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Task.Option

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_students_answers" do
    field :text, :string

    belongs_to :task, Task

    belongs_to :attempt_result, StudentAttemptResult

    many_to_many :selected_options, Option,
      join_through: "test_task_student_answer_selected_options",
      on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  def options_changeset(%__MODULE__{} = student_answer, attrs) do
    student_answer
    |> cast(attrs, [])
    |> cast_assoc(:selected_options, required: true)
  end

  def text_changeset(%__MODULE__{} = student_answer, attrs) do
    student_answer
    |> cast(attrs, [:text])
    |> validate_required(:text)
  end

  def new(fields \\ []) do
    fields =
      [selected_options: []]
      |> Keyword.merge(fields)

    struct!(__MODULE__, fields)
  end

  def select_option(%__MODULE__{} = student_answer, option) do
    Map.update!(student_answer, :selected_options, &[option | &1])
  end

  def correct?(student_answer)

  def correct?(%__MODULE__{text: text, task: %{type: :text} = task}) do
    text_answers = Enum.map(task.options, & &1.text)

    text in text_answers
  end

  def correct?(%__MODULE__{
        task: %{type: :radio},
        selected_options: [selected_option]
      }) do
    selected_option.is_correct
  end

  def correct?(%__MODULE__{
        task: %{type: :checkbox, options: task_options},
        selected_options: selected_options
      }) do
    all_selected_correct?(selected_options) and
      exact_correct_count?(selected_options, task_options)
  end

  def correct?(%__MODULE__{}) do
    false
  end

  defp all_selected_correct?(selected_options) do
    Enum.all?(selected_options, & &1.is_correct)
  end

  defp exact_correct_count?(selected_options, task_options) do
    Enum.count(selected_options) == Enum.count(task_options, & &1.is_correct)
  end
end
