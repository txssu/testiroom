defmodule Testiroom.Exams.Task do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :type, Ecto.Enum, values: [:multiple, :single, :text]
    field :question, :string
    field :shuffle_options, :boolean, default: false
    field :score, :integer
    field :order, :integer

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:question, :type, :shuffle_options, :score, :order, :test_id])
    |> validate_required([:question, :type, :shuffle_options, :order, :test_id])
  end
end
