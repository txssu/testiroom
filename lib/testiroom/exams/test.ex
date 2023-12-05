defmodule Testiroom.Exams.Test do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :author_id, :binary_id
    field :title, :string
    field :description, :string

    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :duration_in_minutes, :integer

    field :show_results_for_student, :boolean, default: true
    field :show_score_for_student, :boolean, default: true
    field :show_grade_for_student, :boolean, default: true
    field :show_answers_for_student, :boolean, default: true

    has_many :tasks, Task, on_replace: :delete, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @all_fields [
    :title,
    :author_id,
    :description,
    :starts_at,
    :ends_at,
    :duration_in_minutes,
    :show_results_for_student,
    :show_score_for_student,
    :show_grade_for_student,
    :show_answers_for_student
  ]

  def changeset(test, attrs) do
    test
    |> cast(attrs, @all_fields)
    |> validate_required(:title)
    |> validate_number(:duration_in_minutes, greater_than: 0)
    |> validate_starts_at()
    |> validate_ends_at()
    |> cast_assoc(:tasks,
      sort_param: :tasks_order,
      drop_param: :tasks_delete,
      required: true,
      required_message: "Необходимо добавить хотя бы одно задание"
    )
  end

  defp validate_starts_at(changeset) do
    case get_field(changeset, :starts_at) do
      nil -> changeset
      _datetime -> validate_required(changeset, [:ends_at])
    end
  end

  defp validate_ends_at(changeset) do
    case get_field(changeset, :ends_at) do
      nil ->
        changeset

      ends_at ->
        starts_at = get_field(changeset, :starts_at)

        changeset
        |> validate_required([:starts_at])
        |> validate_starts_at_ends_at(starts_at, ends_at)
    end
  end

  defp validate_starts_at_ends_at(changeset, nil, _ends_at) do
    changeset
  end

  defp validate_starts_at_ends_at(changeset, starts_at, ends_at) do
    if DateTime.before?(starts_at, ends_at) do
      changeset
    else
      add_error(changeset, :ends_at, "должно быть после начала")
    end
  end

  def new(fields) do
    fields =
      Keyword.merge([tasks: []], fields)

    struct!(__MODULE__, fields)
  end

  def add_task(test = %__MODULE__{}, task = %Task{}) do
    Map.update!(test, :tasks, &[task | &1])
  end
end
