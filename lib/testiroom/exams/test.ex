defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  import Ecto.Changeset
  import TestiroomWeb.Gettext

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Grade
  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :description, :string
    field :title, :string
    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :duration_in_seconds, :integer
    field :duration_in_minutes, :integer, virtual: true
    field :show_correctness_for_student, :boolean, default: true
    field :show_score_for_student, :boolean, default: true
    field :show_grade_for_student, :boolean, default: true
    field :show_answer_for_student, :boolean, default: true

    belongs_to :user, User

    has_many :grades, Grade, on_replace: :delete, preload_order: [desc: :from]
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
      :duration_in_minutes,
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
    |> validate_length(:grades, min: 1)
    |> convert_duration_to_seconds()
    |> validate_grades()
  end

  def convert_duration_to_seconds(changeset) do
    minutes = get_change(changeset, :duration_in_minutes)

    put_change(changeset, :duration_in_seconds, minutes && minutes * 60)
  end

  def validate_grades(changeset) do
    grades = get_field(changeset, :grades)

    if grades == [] or Enum.find(grades, &(&1.from == 0)) do
      changeset
    else
      add_error(changeset, :grades, gettext("should cover values from 0 to 100 (you need to add a grade from 0%)"))
    end
  end
end
