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
    |> cast_answers()
  end

  defp cast_answers(changeset) do
    case get_field(changeset, :type) do
      :text ->
        changeset
        |> cast_assoc(:options, required: true)
        |> validate_length(:options, min: 1)

      type when type in [:radio, :checkbox] ->
        changeset
        |> cast_assoc(:options, required: true)
        |> validate_length(:options, min: 2)

      nil ->
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
