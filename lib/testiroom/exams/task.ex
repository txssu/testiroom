defmodule Testiroom.Exams.Task do
  use Ecto.Schema

  alias Testiroom.Exams.Test
  alias Testiroom.Exams.Task.Option
  alias Testiroom.Exams.Task.TextAnswer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_tasks" do
    field :type, Ecto.Enum, values: [:radio, :checkbox, :text]
    field :question, :string

    belongs_to :test, Test

    has_many :text_answers, TextAnswer
    has_many :options, Option

    timestamps(type: :utc_datetime)
  end
end
