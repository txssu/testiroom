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
end
