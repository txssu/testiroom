defmodule Testiroom.Exams do
  alias Testiroom.Exams.TaskOption
  alias Testiroom.Exams.TestResult
  alias Testiroom.Repo

  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test
  alias Testiroom.Exams.StudentAnswer

  import Ecto.Query, warn: false

  def new_test() do
    %Test{tasks: []}
  end

  def list_tests do
    Repo.all(Test)
  end

  def create_test(attrs) do
    %Test{}
    |> Test.changeset(attrs)
    |> Repo.insert()
  end

  def change_test(test, attrs \\ %{}) do
    Test.changeset(test, attrs)
  end

  def get_test!(test_id) do
    ordered_tasks =
      from task in Task,
        order_by: task.order,
        preload: :options

    Repo.one!(
      from test in Test,
        where: test.id == ^test_id,
        preload: [tasks: ^ordered_tasks]
    )
  end

  def get_test_by_title(title) do
    ordered_tasks =
      from task in Task,
        order_by: task.order,
        preload: :options

    Repo.one(
      from test in Test,
        where: test.title == ^title,
        preload: [tasks: ^ordered_tasks]
    )
  end

  def new_task do
    %Task{}
  end

  def change_task(task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def new_task_option do
    %TaskOption{}
  end

  def new_student_answer(%Task{} = task) do
    %StudentAnswer{
      task: task,
      task_id: task.id,
      selected_options: []
    }
  end

  def edit_student_answer(%StudentAnswer{} = student_answer, attrs) do
    StudentAnswer.changeset(student_answer, attrs)
  end

  def save_results(student_answers, test) do
    %TestResult{student_answers: student_answers, test: test}
    |> Repo.insert!()
    |> Repo.preload(student_answers: [:selected_task_options])
  end

  def get_result(result_id) do
    TestResult
    |> Repo.get!(result_id)
    |> Repo.preload(student_answers: [task: [:options], selected_task_options: []])
  end
end
