defmodule Testiroom.Proctoring.AnswersTracker do
  @moduledoc false
  @behaviour Testiroom.Proctoring.Tracker

  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Proctoring.Event

  @impl Testiroom.Proctoring.Tracker
  def init([]) do
    {:ok, [], [user_answers: %{}, provided_answers_counter: 0, user_answers_correctness: %{}]}
  end

  @impl Testiroom.Proctoring.Tracker
  def call(data, event, []) do
    data
    |> maybe_update_counter(event)
    |> insert_user_answer(event)
    |> set_correctness(event)
  end

  defp maybe_update_counter(data, %Event.ProvidedAnswer{attempt: attempt, student_answer: answer}) do
    result = Map.fetch!(data, :user_answers)

    with {:ok, answers} <- Map.fetch(result, attempt.id),
         {:ok, _answer} <- Map.fetch(answers, answer.task.order) do
      data
    else
      :error ->
        Map.update!(data, :provided_answers_counter, &(&1 + 1))
    end
  end

  defp insert_user_answer(data, %Event.ProvidedAnswer{attempt: attempt, student_answer: answer}) do
    Map.update!(
      data,
      :user_answers,
      &Map.update(&1, attempt.id, %{answer.task.order => answer}, fn answers ->
        Map.put(answers, answer.task.order, answer)
      end)
    )
  end

  defp set_correctness(data, %Event.ProvidedAnswer{attempt: attempt, student_answer: answer}) do
    correct? = StudentAnswer.correct?(answer)

    Map.update!(
      data,
      :user_answers_correctness,
      &Map.update(&1, attempt.id, %{answer.task.order => correct?}, fn answers ->
        Map.put(answers, answer.task.order, correct?)
      end)
    )
  end
end
