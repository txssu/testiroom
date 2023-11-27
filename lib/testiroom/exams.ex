defmodule Testiroom.Exams do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test
  alias Testiroom.Repo

  @type test_changeset :: {:ok, Test.t()} | {:error, Ecto.Changeset.t()}

  @spec list_tests() :: [Test.t()]
  def list_tests do
    Repo.all(Test)
  end

  def get_test!(id) do
    Repo.get!(Test, id)
  end

  @spec change_test(Test.t(), map()) :: Ecto.Changeset.t()
  def change_test(test, attrs \\ %{}) do
    Test.changeset(test, attrs)
  end

  @spec create_test(map()) :: test_changeset()
  def create_test(attrs \\ %{}) do
    %Test{} |> Test.changeset(attrs) |> Repo.insert()
  end

  def update_test(%Test{} = test, attrs \\ %{}) do
    test |> change_test(attrs) |> Repo.update()
  end

  def get_task!(test_id, task_id) do
    query =
      from task in Task,
        where: task.test_id == ^test_id and task.id == ^task_id

    Repo.one!(query)
  end

  def list_tasks_by_order(test_id, order) do
    query =
      from task in Task,
        where: task.test_id == ^test_id and task.order == ^order

    Repo.all(query)
  end

  def get_max_task_order(test_id) do
    query =
      from task in Task,
        where: task.test_id == ^test_id,
        select: max(task.order)

    Repo.one!(query)
  end

  def change_task(task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def create_task(attrs \\ %{}) do
    %Task{} |> change_task(attrs) |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs \\ %{}) do
    task |> change_task(attrs) |> Repo.update()
  end
end
