defmodule Testiroom.Exams.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Test
  alias Testiroom.Exams.TaskOption
  alias Testiroom.Exams.StudentAnswer

  alias Testiroom.Exams.Helper

  @task_types ~w[shortanswer multiple single]a
  @task_types_rus ["Открытый ответ", "Множественный выбор", "Одиночный выбор"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :type, Ecto.Enum, values: @task_types, default: :shortanswer
    field :question, :string
    field :order, :integer
    field :answer, :string

    belongs_to :test, Test
    has_many :options, TaskOption
    has_many :students_answers, StudentAnswer

    field :delete, :boolean, default: false, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:question, :order, :answer, :type, :delete])
    |> validate_required([:question, :order, :type])
    |> validate_answer()
    |> Helper.cast_delete_action()
  end

  def get_type_options do
    Enum.zip(@task_types_rus, @task_types)
  end

  defp validate_answer(changeset) do
    case get_field(changeset, :type) do
      :shortanswer ->
        validate_required(changeset, :answer)

      type when type in ~w[multiple single]a ->
        changeset
        |> cast_assoc(:options,
          required: true,
          required_message: "нужно добавить не менее двух вариантов ответа"
        )
        |> validate_length(:options, min: 2, message: "нужно добавить не менее двух вариантов ответа")
        |> validate_correct_answers_count(type)
    end
  end

  defp validate_correct_answers_count(changeset, :multiple) do
    options = get_field(changeset, :options)

    if Enum.all?(options, &(not &1.is_correct)) do
      add_error(changeset, :options, "должен быть хотя бы один правильный ответ")
    else
      changeset
    end
  end

  defp validate_correct_answers_count(changeset, :single) do
    options = get_field(changeset, :options)

    if Enum.count(options, & &1.is_correct) == 1 do
      changeset
    else
      add_error(changeset, :options, "должен быть ровно один правильный ответ")
    end
  end
end
