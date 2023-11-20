defmodule Testiroom.Exams.Test do
  use Ecto.Schema
  import Ecto.Changeset

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :author_id, :binary_id
    field :title, :string

    has_many :tasks, Task, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  def changeset(test, attrs) do
    test
    |> cast(attrs, [:title])
    |> validate_required(:title)
    |> cast_assoc(:tasks,
      sort_param: :tasks_order,
      drop_param: :tasks_delete,
      required: true,
      required_message: "Необходимо добавить хотя бы одно задание"
    )
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
