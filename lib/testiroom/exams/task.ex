defmodule Testiroom.Exams.Task do
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Test
  alias Testiroom.Exams.Task.Option

  @task_types ~w[radio checkbox text]a
  @task_types_rus ["Одиночный выбор", "Множественный выбор", "Открытый вопрос"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_tasks" do
    field :type, Ecto.Enum, values: [:radio, :checkbox, :text]
    field :question, :string

    belongs_to :test, Test

    has_many :options, Option, on_delete: :delete_all

    field :delete, :boolean, virtual: true

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = task, attrs) do
    task
    |> cast(attrs, [:question, :type])
    |> validate_required([:question, :type])
    |> cast_assoc(:options,
      sort_param: :options_order,
      drop_param: :options_delete,
      required: true
    )
    |> validate_options_count()
    |> validate_correct_options_count()
  end

  defp validate_options_count(changeset) do
    case get_field(changeset, :type) do
      :text -> validate_length(changeset, :options, min: 1)
      type when type in [:radio, :checkbox] -> validate_length(changeset, :options, min: 2)
      nil -> changeset
    end
  end

  defp validate_correct_options_count(changeset) do
    correct_count =
      changeset
      |> get_field(:options)
      |> Enum.count(& &1.is_correct)

    case get_field(changeset, :type) do
      :checkbox ->
        if correct_count >= 1 do
          changeset
        else
          add_error(changeset, :options, "Должен быть хотя бы один верный ответ")
        end

      :radio ->
        if correct_count == 1 do
          changeset
        else
          add_error(changeset, :options, "Должен быть ровно один верный ответ")
        end

      _other ->
        changeset
    end
  end

  def new(fields \\ []) do
    fields = Keyword.merge(fields, options: [])

    struct!(__MODULE__, fields)
  end

  def get_type_options do
    Enum.zip(@task_types_rus, @task_types)
  end
end
