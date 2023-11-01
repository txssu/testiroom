defmodule Testiroom.Exams.TestResult do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Test
  alias Testiroom.Exams.StudentAnswer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_results" do
    belongs_to :test, Test
    has_many :student_answers, StudentAnswer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test_result, attrs) do
    test_result
    |> cast(attrs, [])
    |> validate_required([])
  end
end
