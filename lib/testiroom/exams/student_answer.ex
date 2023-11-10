defmodule Testiroom.Exams.StudentAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "students_answers" do
    field :text, :string

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student_answer, attrs) do
    student_answer
    |> cast(attrs, [:text])
  end
end
