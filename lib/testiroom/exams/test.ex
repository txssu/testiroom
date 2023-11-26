defmodule Testiroom.Exams.Test do
  use Ecto.Schema

  alias Testiroom.Exams.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :title, :string

    has_many :tasks, Task, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  def new(title) do
    %__MODULE__{title: title, tasks: []}
  end

  def add_task(test = %__MODULE__{}, task = %Task{}) do
    Map.update!(test, :tasks, &[task | &1])
  end
end
