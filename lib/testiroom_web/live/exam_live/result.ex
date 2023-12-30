defmodule TestiroomWeb.ExamLive.Result do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.Attempt

  def mount(%{"attempt_id" => id}, _session, socket) do
    attempt = Exams.get_attempt!(id)
    now = DateTime.utc_now()

    if attempt.ended_at && DateTime.before?(now, attempt.ended_at) do
      {:ok, socket |> put_flash(:error, gettext("Finish the test first")) |> push_navigate(to: ~p"/exams/#{id}/0")}
    else
      result = gettext("Result")
      page_title = "#{result} · #{attempt.test.title}"

      {score, max_score} = Attempt.get_score_and_max_score(attempt)
      grade = Attempt.get_grade(attempt)

      {:ok,
       socket
       |> assign(:page_title, page_title)
       |> assign(:attempt, attempt)
       |> assign(:test, attempt.test)
       |> assign(:score, score)
       |> assign(:max_score, max_score)
       |> assign(:grade, grade)}
    end
  end

  def handle_params(%{"order" => order_param}, _uri, socket) do
    order = String.to_integer(order_param)
    attempt = socket.assigns.attempt

    answer =
      Enum.find(attempt.student_answers, &(&1.order == order))

    selected_option_ids = Enum.map(answer.selected_options, & &1.id)

    {:noreply,
     socket
     |> assign(:answer, answer)
     |> assign(:selected_option_ids, selected_option_ids)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
