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

    has_many :student_answers, StudentAnswer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attempt, attrs) do
    attempt
    |> cast(attrs, [:ended_at])
    |> validate_required([:ended_at])
  end
end
