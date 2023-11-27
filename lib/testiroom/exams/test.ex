defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :description, :string
    field :title, :string
    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :duration, :time
    field :show_results, :boolean, default: true
    field :show_score, :boolean, default: true
    field :show_grade, :boolean, default: true
    field :show_answers, :boolean, default: true

    has_many :tasks, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> cast(attrs, [:title, :description, :starts_at, :ends_at, :duration, :show_results, :show_score, :show_grade, :show_answers])
    |> validate_required([:title, :show_results, :show_score, :show_grade, :show_answers])
  end
end
