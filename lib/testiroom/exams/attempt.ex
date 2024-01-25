defmodule Testiroom.Exams.Attempt do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "attempts" do
    field :ended_at, :utc_datetime

    belongs_to :user, User
    belongs_to :test, Test

    has_many :student_answers, StudentAnswer, preload_order: [asc: :order]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attempt, attrs) do
    cast(attempt, attrs, [:ended_at])
  end

  def get_score_and_max_score(attempt) do
    {scores, max_scores} =
      attempt.student_answers
      |> Enum.map(&StudentAnswer.get_score/1)
      |> Enum.unzip()

    score = Enum.sum(scores)
    max_score = Enum.sum(max_scores)

    {score, max_score}
  end

  def get_correctness_ratio(attempt) do
    {score, max_score} = get_score_and_max_score(attempt)

    score / max_score * 100
  end

  def get_grade(attempt) do
    ratio = get_correctness_ratio(attempt)
    Enum.find(attempt.test.grades, fn grade -> ratio >= grade.from end)
  end
end
