defmodule Testiroom.Exams.Option do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_options" do
    field :text, :string
    field :is_correct, :boolean, default: false

    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:text, :is_correct])
    |> validate_required([:text, :is_correct])
  end
end
