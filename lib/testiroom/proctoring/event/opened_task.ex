defmodule Testiroom.Proctoring.Event.OpenedTask do
  @moduledoc false
  use Ecto.Schema

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "opened_tasks_events" do
    belongs_to :test, Test
    belongs_to :attempt, Attempt
    belongs_to :task, Task

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
