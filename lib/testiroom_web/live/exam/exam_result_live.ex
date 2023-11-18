defmodule TestiroomWeb.ExamResultLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.StudentAnswer

  def mount(%{"id" => result_id}, _session, socket) do
    result = Exams.get_attempt_result(result_id)
    page_title = fetch_page_title(result)
    {:ok, assign(socket, page_title: page_title, result: result)}
  end

  defp fetch_page_title(result) do
    test_title =
      result
      |> Map.fetch!(:answers)
      |> List.first()
      |> Map.fetch!(:task)
      |> Map.fetch!(:test)
      |> Map.fetch!(:title)

    "Результаты · #{test_title}"
  end
end
