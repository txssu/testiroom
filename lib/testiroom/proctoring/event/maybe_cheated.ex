defmodule Testiroom.Proctoring.Event.MaybeCheated do
  @moduledoc false
  use Ecto.Schema

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "maybe_cheated_events" do
    field :process, Ecto.Enum, values: [:started, :ended]

    belongs_to :test, Test
    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
