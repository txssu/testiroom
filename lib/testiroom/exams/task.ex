defmodule Testiroom.Exams.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Test

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :type, Ecto.Enum, values: [:mulitple, :single, :text], default: :single
    field :order, :integer
    field :question, :string
    field :media_path, :string
    field :shuffle_options, :boolean, default: false
    field :score, :integer, default: 1

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:order, :type, :question, :media_path, :shuffle_options, :score])
    |> validate_required([:order, :type, :question, :score])
  end
end
