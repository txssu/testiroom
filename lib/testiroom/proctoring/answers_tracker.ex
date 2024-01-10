defmodule Testiroom.Proctoring.AnswersTracker do
  @moduledoc false
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Proctoring.Event

  def init([]) do
    {:ok, [], [user_answers: %{}, provided_answers_counter: 0, user_answers_correctness: %{}]}
  end

  def call(data, event, []) do
    data
    |> maybe_update_counter(event)
    |> insert_user_answer(event)
    |> set_correctness(event)
  end

  defp maybe_update_counter(data, %Event.ProvidedAnswer{user: user, answer: answer}) do
    result = Map.fetch!(data, :user_answers)

    with {:ok, answers} <- Map.fetch(result, user.id),
         {:ok, _answer} <- Map.fetch(answers, answer.task.order) do
      data
    else
      :error ->
        Map.update!(data, :provided_answers_counter, &(&1 + 1))
    end
  end

  defp insert_user_answer(data, %Event.ProvidedAnswer{user: user, answer: answer}) do
    Map.update!(
      data,
      :user_answers,
      &Map.update(&1, user.id, %{answer.task.order => answer}, fn answers -> Map.put(answers, answer.task.order, answer) end)
    )
  end

  defp set_correctness(data, %Event.ProvidedAnswer{user: user, answer: answer}) do
    correct? = StudentAnswer.correct?(answer)

    Map.update!(
      data,
      :user_answers_correctness,
      &Map.update(&1, user.id, %{answer.task.order => correct?}, fn answers ->
        Map.put(answers, answer.task.order, correct?)
      end)
    )
  end
end
