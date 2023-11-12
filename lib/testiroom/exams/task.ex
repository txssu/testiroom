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

    has_many :text_answers, TextAnswer, on_delete: :delete_all
    has_many :options, Option, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  def new(fields) do
    fields = Keyword.merge(fields, options: [], text_answers: [])

    struct!(__MODULE__, fields)
  end

  def add_text_answer(task = %__MODULE__{}, text) when is_binary(text) do
    text_answer = TextAnswer.new(text)
    Map.update!(task, :text_answers, &[text_answer | &1])
  end

  def add_option(task = %__MODULE__{}, text, correct?) when is_binary(text) do
    option = Option.new(text, correct?)
    Map.update!(task, :options, &[option | &1])
  end
end
