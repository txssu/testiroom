defmodule Testiroom.Exams.Attempt do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Grade
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "attempts" do
    field :ended_at, :utc_datetime

    field :score, :integer
    field :max_score, :integer
    belongs_to :grade, Grade

    belongs_to :user, User
    belongs_to :test, Test

    has_many :student_answers, StudentAnswer, preload_order: [asc: :order]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attempt, attrs) do
    cast(attempt, attrs, [:ended_at, :score, :max_score, :grade_id])
  end
end
