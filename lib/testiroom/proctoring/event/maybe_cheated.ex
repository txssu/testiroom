defmodule Testiroom.Proctoring.Event.MaybeCheated do
  @moduledoc false
  use Ecto.Schema

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "maybe_cheated_events" do
    field :process, Ecto.Enum, values: [:started, :ended]

    belongs_to :test, Test
    belongs_to :attempt, Attempt

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
