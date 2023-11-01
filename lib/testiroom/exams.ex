defmodule Testiroom.Exams do
  alias Testiroom.Exams.TestResult
  alias Testiroom.Repo

  alias Testiroom.Exams.Task
  alias Testiroom.Exams.Test
  alias Testiroom.Exams.StudentAnswer

  import Ecto.Query, warn: false

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
