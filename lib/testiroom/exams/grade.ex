defmodule Testiroom.Exams.Grade do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "grades" do
    field :from, :integer
    field :grade, :string

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:grade, :from])
    |> validate_required([:grade, :from])
  end
end
