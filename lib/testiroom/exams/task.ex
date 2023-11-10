defmodule Testiroom.Exams.Task do
  use Ecto.Schema

  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_tasks" do
    field :type, Ecto.Enum, values: [:radio, :checkbox, :text]
    field :question, :string

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end
end
