defmodule Testiroom.Exams.Task do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Testiroom.Exams.Test
  import TestiroomWeb.Gettext

  @types [:multiple, :single, :text]
  @types_names [gettext("Multiple choice"), gettext("Single choice"), gettext("Text input")]

  length(@types) == length(@types_names) || raise """
  Types and type names length have to be same
  """

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :type, Ecto.Enum, values: [:multiple, :single, :text]
    field :question, :string
    field :shuffle_options, :boolean, default: false
    field :score, :integer, default: 1
    field :order, :integer

    belongs_to :test, Test

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:question, :type, :shuffle_options, :score, :order, :test_id])
    |> validate_required([:question, :shuffle_options, :order, :test_id])
  end

  def types do
    Enum.zip(@types_names, @types)
  end
end
