defmodule Testiroom.Exams.Task do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import TestiroomWeb.Gettext

  alias Testiroom.Exams.Option
  alias Testiroom.Exams.Test

  @types ~w[multiple single text]a
  @type_names [gettext("Multiple select"), gettext("Single select"), gettext("Text input")]
  @types_with_names Enum.zip(@type_names, @types)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :type, Ecto.Enum, values: @types, default: :single
    field :order, :integer
    field :question, :string
    field :media_path, :string
    field :shuffle_options, :boolean, default: false
    field :score, :integer, default: 1

    belongs_to :test, Test

    has_many :options, Option, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:order, :type, :question, :media_path, :shuffle_options, :score])
    |> validate_required([:order, :type, :question, :score])
    |> cast_assoc(:options,
      sort_param: :options_order,
      drop_param: :options_delete
    )
  end

  def types, do: @types_with_names


  for {name, type} <- @types_with_names do
    def type_to_name(unquote(type)), do: unquote(name)
  end
end
