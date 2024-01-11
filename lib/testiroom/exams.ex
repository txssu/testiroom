defmodule Testiroom.Exams do
  @moduledoc """
  The Exams context.
  """

  import Ecto.Query, warn: false

  alias Testiroom.Accounts.User
  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.Grade
  alias Testiroom.Exams.Option
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
  Returns the list of grades.

  ## Examples

      iex> list_grades()
      [%Grade{}, ...]

  """
  def list_grades do
    Repo.all(Grade)
  end

  @doc """
  Gets a single grade.

  Raises `Ecto.NoResultsError` if the Grade does not exist.

  ## Examples

      iex> get_grade!(123)
      %Grade{}

      iex> get_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grade!(id), do: Repo.get!(Grade, id)

  @doc """
  Creates a grade.

  ## Examples

      iex> create_grade(%{field: value})
      {:ok, %Grade{}}

      iex> create_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grade(attrs \\ %{}) do
    %Grade{}
    |> Grade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grade.

  ## Examples

      iex> update_grade(grade, %{field: new_value})
      {:ok, %Grade{}}

      iex> update_grade(grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grade(%Grade{} = grade, attrs) do
    grade
    |> Grade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a grade.

  ## Examples

      iex> delete_grade(grade)
      {:ok, %Grade{}}

      iex> delete_grade(grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grade(%Grade{} = grade) do
    Repo.delete(grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grade changes.

  ## Examples

      iex> change_grade(grade)
      %Ecto.Changeset{data: %Grade{}}

  """
  def change_grade(%Grade{} = grade, attrs \\ %{}) do
    Grade.changeset(grade, attrs)
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

  @doc """
  Returns the list of task_options.

  ## Examples

      iex> list_task_options()
      [%Option{}, ...]

  """
  def list_task_options do
    Repo.all(Option)
  end

  @doc """
  Gets a single option.

  Raises `Ecto.NoResultsError` if the Option does not exist.

  ## Examples

      iex> get_option!(123)
      %Option{}

      iex> get_option!(456)
      ** (Ecto.NoResultsError)

  """
  def get_option!(id), do: Repo.get!(Option, id)

  @doc """
  Creates a option.

  ## Examples

      iex> create_option(%{field: value})
      {:ok, %Option{}}

      iex> create_option(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_option(attrs \\ %{}) do
    %Option{}
    |> Option.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a option.

  ## Examples

      iex> update_option(option, %{field: new_value})
      {:ok, %Option{}}

      iex> update_option(option, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_option(%Option{} = option, attrs) do
    option
    |> Option.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a option.

  ## Examples

      iex> delete_option(option)
      {:ok, %Option{}}

      iex> delete_option(option)
      {:error, %Ecto.Changeset{}}

  """
  def delete_option(%Option{} = option) do
    Repo.delete(option)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking option changes.

  ## Examples

      iex> change_option(option)
      %Ecto.Changeset{data: %Option{}}

  """
  def change_option(%Option{} = option, attrs \\ %{}) do
    Option.changeset(option, attrs)
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

  def get_attempt!(id), do: Attempt |> Repo.get!(id) |> Repo.preload(student_answers: [task: [:options], selected_options: []], test: [:grades]) |> maybe_shuffle_options()

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

  def change_student_answer(%StudentAnswer{} = student_answer, attrs \\ %{}) do
    StudentAnswer.changeset(student_answer, attrs)
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
