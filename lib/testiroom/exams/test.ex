defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Grade
  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :description, :string
    field :title, :string
    field :starts_at, :naive_datetime
    field :ends_at, :naive_datetime
    field :duration_in_seconds, :integer
    field :show_correctness_for_student, :boolean, default: true
    field :show_score_for_student, :boolean, default: true
    field :show_grade_for_student, :boolean, default: true
    field :show_answer_for_student, :boolean, default: true

    belongs_to :user, User

    has_many :grades, Grade, on_replace: :delete
    has_many :tasks, Task, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> cast(attrs, [
      :title,
      :description,
      :starts_at,
      :ends_at,
      :duration_in_seconds,
      :show_correctness_for_student,
      :show_score_for_student,
      :show_grade_for_student,
      :show_answer_for_student
    ])
    |> validate_required([:title, :show_correctness_for_student, :show_score_for_student, :show_grade_for_student, :show_answer_for_student])
    |> cast_assoc(:grades,
      sort_param: :grades_order,
      drop_param: :grades_delete
    )
  end
end
