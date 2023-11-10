defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :title, :string

    timestamps(type: :utc_datetime)
  end
end
