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

  def change_task(test, attrs \\ %{}) do
    Task.changeset(test, attrs)
  end

  def create_task(attrs \\ %{}) do
    %Task{} |> change_task(attrs) |> Repo.insert()
  end

  def update_task(%Task{} = test, attrs \\ %{}) do
    test |> change_task(attrs) |> Repo.update()
  end
end
