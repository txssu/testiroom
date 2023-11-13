defmodule Testiroom.Exams do
  alias Testiroom.Repo
  import Ecto.Query, warn: false

  alias Testiroom.Exams.Test

  def list_tests do
    Repo.all(Test)
  end

  def get_test(id) do
    Test
    |> Repo.get(id)
    |> Repo.preload(tasks: [:options, :text_answers])
  end

  alias Testiroom.Exams.{StudentAnswer, StudentAttempt, AttemptManager}

  def start_attempt(user, test) do
    attempt = StudentAttempt.new(test)

    with {:ok, _pid} <- AttemptManager.start_attempt(user, attempt) do
      {:ok, {user.id, test.id}}
    else
      error -> error
    end
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
