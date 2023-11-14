defmodule TestiroomWeb.ExamResultLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.StudentAnswer

  def mount(%{"id" => result_id}, _session, socket) do
    result = Exams.get_attempt_result(result_id)
    {:ok, assign(socket, result: result)}
  end
end
