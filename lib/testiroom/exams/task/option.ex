defmodule Testiroom.Exams.Task.Option do
  use Ecto.Schema

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_options" do
    field :text, :string
    field :is_correct, :boolean

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  def new(text, correct?) do
    %__MODULE__{text: text, is_correct: correct?}
  end
end
