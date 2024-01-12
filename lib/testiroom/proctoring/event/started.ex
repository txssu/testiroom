defmodule Testiroom.Proctoring.Event.Started do
  @moduledoc false
  use Ecto.Schema

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "started_events" do
    belongs_to :test, Test
    belongs_to :attempt, Attempt

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
