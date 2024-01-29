defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  import Ecto.Changeset
  import TestiroomWeb.Gettext

  alias Ecto.Changeset
  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Grade
  alias Testiroom.Exams.Task

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :description, :string
    field :title, :string

    field :timezone, :string, virtual: true, default: "Etc/UTC"

    field :starts_at_local, :naive_datetime, virtual: true
    field :starts_at, :utc_datetime

    field :ends_at_local, :naive_datetime, virtual: true
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
  @spec changeset(Ecto.Schema.t(), map()) :: Changeset.t()
  def changeset(test, attrs) do
    test
    |> cast(attrs, [
      :title,
      :description,
      :timezone,
      :starts_at_local,
      :ends_at_local,
      :duration_in_minutes,
      :show_correctness_for_student,
      :show_score_for_student,
      :show_grade_for_student,
      :show_answer_for_student
    ])
    |> validate_required([
      :title,
      :show_correctness_for_student,
      :show_score_for_student,
      :show_grade_for_student,
      :show_answer_for_student
    ])
    |> cast_assoc(:grades,
      sort_param: :grades_order,
      drop_param: :grades_delete
    )
    |> validate_length(:grades, min: 1)
    |> convert_local_time_to_utc()
    |> convert_duration_to_seconds()
    |> validate_grades()
  end

  @spec convert_local_time_to_utc(Changeset.t()) :: Changeset.t()
  defp convert_local_time_to_utc(changeset) do
    for {local_key, utc_key} <- [{:starts_at_local, :starts_at}, {:ends_at_local, :ends_at}], reduce: changeset do
      inner_changeset ->
        case get_field(inner_changeset, local_key) do
          nil ->
            put_change(inner_changeset, utc_key, nil)

          ~N[0000-01-01 00:00:00] ->
            inner_changeset

          local ->
            timezone = get_field(inner_changeset, :timezone)
            utc_datetime = local |> DateTime.from_naive!(timezone) |> DateTime.shift_zone!("Etc/UTC")
            put_change(inner_changeset, utc_key, utc_datetime)
        end
    end
  end

  @spec convert_duration_to_seconds(Changeset.t()) :: Changeset.t()
  defp convert_duration_to_seconds(changeset) do
    minutes = get_change(changeset, :duration_in_minutes)

    put_change(changeset, :duration_in_seconds, minutes && minutes * 60)
  end

  @spec validate_grades(Changeset.t()) :: Changeset.t()
  defp validate_grades(changeset) do
    grades = get_field(changeset, :grades)

    if grades == [] or Enum.find(grades, &(&1.from == 0)) do
      changeset
    else
      add_error(changeset, :grades, gettext("should cover values from 0 to 100 (you need to add a grade from 0%)"))
    end
  end
end
