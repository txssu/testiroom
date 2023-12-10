defmodule Testiroom.Exams.Option do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_options" do
    field :text, :string
    field :is_correct, :boolean, default: false

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:text, :is_correct])
    |> validate_required([:text, :is_correct])
  end
end
