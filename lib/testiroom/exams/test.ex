defmodule Testiroom.Exams.Test do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :title, :string

    has_many :tasks, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> cast(attrs, [:title])
    |> cast_assoc(:tasks)
    |> validate_required([:title])
  end
end
