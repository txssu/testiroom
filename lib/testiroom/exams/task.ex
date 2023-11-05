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
    |> cast_assoc(:options)
    |> validate_required([:question, :order, :type])
    |> Helper.cast_delete_action()
  end

  def get_type_options do
    Enum.zip(@task_types_rus, @task_types)
  end
end
