defmodule Testiroom.Exams.Task.TextAnswer do
  use Ecto.Schema

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_text_answers" do
    field :text, :string

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  def new(text) do
    %__MODULE__{text: text}
  end
end
