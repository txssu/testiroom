defmodule Testiroom.Exams.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Test
  alias Testiroom.Exams.StudentAnswer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :type, Ecto.Enum, values: [:shortanswer]
    field :question, :string
    field :order, :integer
    field :answer, :string

    belongs_to :test, Test
    has_many :students_answers, StudentAnswer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:question, :order, :answer, :type])
    |> validate_required([:question, :order, :answer, :type])
  end
end
