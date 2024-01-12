defmodule Testiroom.Proctoring.Event.ProvidedAnswer do
  @moduledoc false
  use Ecto.Schema

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "provided_answer_events" do
    belongs_to :test, Test
    belongs_to :attempt, Attempt
    belongs_to :student_answer, StudentAnswer

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
