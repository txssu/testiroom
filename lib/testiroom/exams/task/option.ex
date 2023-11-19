defmodule Testiroom.Exams.Task.Option do
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "test_task_options" do
    field :text, :string
    field :is_correct, :boolean

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = option, attrs) do
    option
    |> cast(attrs, [:text, :is_correct])
    |> validate_required([:text, :is_correct])
  end

  def new() do
    %__MODULE__{}
  end
end
