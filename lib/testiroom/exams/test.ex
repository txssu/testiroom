defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :title, :string

    has_many :tasks, Task

    timestamps(type: :utc_datetime)
  end
end
