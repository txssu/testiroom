defmodule Testiroom.Exams do
  @moduledoc """
  The Exams context.
  """

  import Ecto.Query, warn: false

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Grade
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test
  alias Testiroom.Repo

  @doc """
  Returns the list of tests.

  ## Examples

      iex> list_user_tests(user_id)
      [%Test{}, ...]

  """
  def list_user_tests(user_id) do
    query =
      from test in Test,
        where: test.user_id == ^user_id

    Repo.all(query)
  end

  def list_tests, do: Repo.all(Test)

  @doc """
  Gets a single test.

  Raises `Ecto.NoResultsError` if the Test does not exist.

  ## Examples

      iex> get_test!(123)
      %Test{}

      iex> get_test!(456)
      ** (Ecto.NoResultsError)

  """
  def get_test!(id), do: Test |> Repo.get!(id) |> Repo.preload([:grades, :tasks])

  @doc """
  Creates a test.

  ## Examples

      iex> create_test(%{field: value}, user)
      {:ok, %Test{}}

      iex> create_test(%{field: bad_value}, user)
      {:error, %Ecto.Changeset{}}

  """
  def create_test(attrs \\ %{}, %User{} = user) do
    user
    |> Ecto.build_assoc(:tests)
    |> Map.put(:grades, Grade.default_grades())
    |> Test.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a test.

  ## Examples

      iex> update_test(test, %{field: new_value})
      {:ok, %Test{}}

      iex> update_test(test, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_test(%Test{} = test, attrs) do
    test
    |> Test.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a test.

  ## Examples

      iex> delete_test(test)
      {:ok, %Test{}}

      iex> delete_test(test)
      {:error, %Ecto.Changeset{}}

  """
  def delete_test(%Test{} = test) do
    Repo.delete(test)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking test changes.

  ## Examples

      iex> change_test(test)
      %Ecto.Changeset{data: %Test{}}

  """
  def change_test(%Test{} = test, attrs \\ %{}) do
    Test.changeset(test, attrs)
  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks(test_id, order)
      [%Task{}, ...]

  """
  def list_tasks(test_id, order) do
    query =
      from task in Task,
        where: task.test_id == ^test_id and task.order == ^order,
        order_by: task.inserted_at

    Repo.all(query)
  end

  def get_max_task_order(test_id) do
    query =
      from task in Task,
        where: task.test_id == ^test_id,
        select: max(task.order)

    Repo.one(query)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Task |> Repo.get!(id) |> Repo.preload(:options)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}, test) do
    test
    |> Ecto.build_assoc(:tasks)
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def start_attempt(user, test) do
    attempt = maybe_add_ended_at(%Attempt{user: user, test: test})

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:attempt, attempt)
      |> Ecto.Multi.run(:student_answers, fn _repo, %{attempt: attempt} ->
        tasks = get_varitant(test)
        create_answers(attempt, tasks)
      end)

    case Repo.transaction(multi) do
      {:ok, %{attempt: attempt}} -> {:ok, get_attempt!(attempt.id)}
      {:error, _failed_operation, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  def wrap_up_attempt!(attempt) do
    attrs =
      maybe_update_ended_time(%{}, attempt)

    attempt
    |> Attempt.changeset(attrs)
    |> Repo.update!()
  end

  def maybe_update_ended_time(attrs, attempt) do
    now = DateTime.utc_now()

    if is_nil(attempt.ended_at) or DateTime.before?(now, attempt.ended_at) do
      Map.put(attrs, :ended_at, now)
    else
      attrs
    end
  end

  defp maybe_add_ended_at(attempt) do
    if duration = attempt.test.duration_in_seconds do
      now = DateTime.utc_now(:second)
      ended_at = DateTime.add(now, duration, :second)
      %{attempt | ended_at: ended_at}
    else
      attempt
    end
  end

  defp get_varitant(test) do
    test.tasks
    |> Enum.group_by(& &1.order)
    |> Enum.map(fn {_order, tasks} ->
      Enum.random(tasks)
    end)
  end

  defp create_answers(attempt, tasks) do
    multi =
      tasks
      |> Stream.with_index()
      |> Enum.reduce(
        Ecto.Multi.new(),
        fn {task, index}, multi ->
          Ecto.Multi.insert(multi, index, %StudentAnswer{order: task.order, attempt: attempt, task: task})
        end
      )

    case Repo.transaction(multi) do
      {:ok, answers} -> {:ok, answers}
      {:error, _failed_operation, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  def get_attempt!(id),
    do: Attempt |> Repo.get!(id) |> Repo.preload(user: [], student_answers: [task: [:options], selected_options: []], test: [:grades]) |> maybe_shuffle_options()

  def maybe_shuffle_options(attempt) do
    Map.update!(attempt, :student_answers, fn answers ->
      Enum.map(answers, fn answer ->
        Map.update!(answer, :task, &maybe_shuffle_task_options/1)
      end)
    end)
  end

  defp maybe_shuffle_task_options(task) do
    if task.shuffle_options do
      Map.update!(task, :options, &Enum.shuffle/1)
    else
      task
    end
  end

  def change_student_answer(%StudentAnswer{} = student_answer) do
    StudentAnswer.changeset(student_answer, %{})
  end

  def update_student_answer(%StudentAnswer{} = student_answer, selected_options, attrs) do
    answer_in_db = Repo.get!(Attempt, student_answer.attempt_id)
    now = DateTime.utc_now()

    if is_nil(answer_in_db.ended_at) or DateTime.before?(now, answer_in_db.ended_at) do
      student_answer
      |> StudentAnswer.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:selected_options, selected_options)
      |> Repo.update()
    else
      {:error, :attempt_is_ended}
    end
  end
end
