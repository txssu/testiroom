defmodule TestiroomWeb.ExamResultLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.StudentAttemptResult

  def mount(%{"id" => result_id}, _session, socket) do
    result = Exams.get_attempt_result(result_id)
    test = fetch_test(result)
    page_title = "Результаты · #{test.title}"
    correct_list = StudentAttemptResult.get_correct_as_list(result)
    score = Enum.count(correct_list, & &1)
    max_score = Enum.count(correct_list)
    grade = StudentAttemptResult.get_grade(score / max_score)

    {:ok,
     assign(socket,
       test: test,
       page_title: page_title,
       score: score,
       max_score: max_score,
       grade: grade,
       correct_list: correct_list,
       result: result
     )}
  end

  def handle_params(%{"index" => index}, _uri, socket) do
    index = String.to_integer(index)

    answer =
      socket.assigns.result.answers
      |> Enum.at(index)

    selected_option_ids = Enum.map(answer.selected_options, & &1.id)

    {:noreply,
     assign(socket, answer: answer, index: index, selected_option_ids: selected_option_ids)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp fetch_test(result) do
    result
    |> Map.fetch!(:answers)
    |> List.first()
    |> Map.fetch!(:task)
    |> Map.fetch!(:test)
  end
end
