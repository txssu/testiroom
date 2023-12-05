defmodule Testiroom.Exams do
  alias Testiroom.Repo
  import Ecto.Query, warn: false

  alias Testiroom.Exams.Test
  alias Testiroom.Exams.{StudentAttempt, AttemptManager, StudentAttemptResult}
  alias Testiroom.Exams.StudentAnswer

  def list_tests do
    Repo.all(Test)
  end

  def get_test(id) do
    Test
    |> Repo.get(id)
    |> Repo.preload(tasks: [:options, :media])
  end

  def change_test(test, attrs \\ %{}) do
    Test.changeset(test, attrs)
  end

  def create_test(test, attrs) do
    test
    |> Test.changeset(attrs)
    |> Repo.insert()
  end

  def update_test(test, attrs) do
    test
    |> Test.changeset(attrs)
    |> Repo.update()
  end

  def insert_answers(answers) do
    answers
    |> StudentAttemptResult.new()
    |> Repo.insert()
  end

  def get_attempt_result(result_id) do
    StudentAttemptResult
    |> Repo.get!(result_id)
    |> Repo.preload(answers: [task: [:test, :options, :media], selected_options: []])
  end

  # StudentAttempt API

  def start_attempt(user, test) do
    now = DateTime.now!("Etc/UTC") |> DateTime.add(5, :hour)

    attempt = StudentAttempt.new(test, now)

    with {:ok, _pid} <- AttemptManager.start_attempt(user, attempt) do
      {:ok, {user.id, test.id}}
    else
      error -> error
    end
  end

  def attempt_started?(attempt) do
    AttemptManager.started?(attempt)
  end

  def get_started_at(attempt) do
    AttemptManager.get_started_at(attempt)
  end

  def get_tasks_count(attempt) do
    AttemptManager.get_tasks_count(attempt)
  end

  def get_task_and_answer(attempt, index) do
    AttemptManager.get_task_and_answer(attempt, index)
  end

  def answer_task_with_text(attempt, index, text) do
    StudentAnswer.new()
    |> StudentAnswer.text_changeset(%{text: text})
    |> apply_changeset(attempt, index)
  end

  def answer_task_with_options(attempt, index, options) do
    StudentAnswer.new(selected_options: options)
    |> StudentAnswer.options_changeset(%{})
    |> apply_changeset(attempt, index)
  end

  defp apply_changeset(changeset, attempt, index) do
    changeset
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, answer} ->
        AttemptManager.answer_task(attempt, index, answer)

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def answer_task(attempt, index, answer) do
    AttemptManager.answer_task(attempt, index, answer)
  end

  def wrap_up_attempt(attempt) do
    AttemptManager.wrap_up(attempt)
  end
end
