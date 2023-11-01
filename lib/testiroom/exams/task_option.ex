defmodule Testiroom.Exams.TaskOption do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_options" do
    field :text, :string
    field :is_correct, :boolean
    field :task_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_option, attrs) do
    task_option
    |> cast(attrs, [:text, :is_correct])
    |> validate_required([:text, :is_correct])
  end
end
