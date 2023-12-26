defmodule TestiroomWeb.ExamLive.Testing do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.ExamLive.Components.BottomModal

  alias Testiroom.Exams
  alias Testiroom.Proctoring
  alias TestiroomWeb.ExamLive.Components.AnswerForm

  @impl Phoenix.LiveView
  def mount(%{"attempt_id" => id}, _session, socket) do
    attempt = Exams.get_attempt!(id)

    cond do
      attempt.user_id != socket.assigns.current_user.id ->
        navigate_with_error(
          socket,
          gettext("You do not have permission to open other testing sessions."),
          ~p"/tests/#{attempt.test_id}/exam"
        )

      Proctoring.examinee_passing_test?(id) ->
        navigate_with_error(
          socket,
          gettext("You have already opened this attempt in another tab."),
          ~p"/tests/#{attempt.test_id}/exam"
        )

      true ->
        answers = Map.new(attempt.student_answers, &{&1.order, &1})

        Proctoring.register_examinee(attempt.id)

        {:ok,
         socket
         |> assign(:attempt, attempt)
         |> assign(:answers, answers)
         |> assign(:max_order, answers |> Map.keys() |> Enum.max())
         |> check_attempt_duration()}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(%{"order" => order_param}, _uri, socket) do
    order = String.to_integer(order_param)
    %{attempt: attempt, answers: answers, max_order: max_order} = socket.assigns

    {:noreply,
     socket
     |> assign(:page_title, page_title(attempt, order))
     |> assign(:order, order)
     |> assign(:previous_order, max(0, order - 1))
     |> assign(:next_order, min(max_order, order + 1))
     |> assign(:current_answer, answers[order])
     |> notify_open_task()}
  end

  @impl Phoenix.LiveView
  def handle_info({AnswerForm, :attempt_is_ended}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("Your attempt has already been completed."))
     |> push_navigate(to: ~p"/exams/#{socket.assigns.attempt}/result")}
  end

  def handle_info({AnswerForm, answer}, socket) do
    %{answers: answers, order: order} = socket.assigns

    {:noreply,
     socket
     |> assign(:current_answer, answer)
     |> assign(:answers, Map.put(answers, order, answer))
     |> notify_answer(answer)}
  end

  @impl Phoenix.LiveView
  def handle_info(:wrap_up, socket) do
    {:noreply, wrap_up(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("wrap-up", _params, socket) do
    {:noreply, wrap_up(socket)}
  end

  def wrap_up(socket) do
    student_answers = Enum.map(socket.assigns.answers, &elem(&1, 1))

    attempt = Map.put(socket.assigns.attempt, :student_answers, student_answers)

    Exams.wrap_up_attempt!(attempt)

    socket
    |> push_navigate(to: ~p"/exams/#{attempt}/result")
    |> notify_wrap_up()
  end

  defp navigate_with_error(socket, message, url) do
    {:ok, socket |> put_flash(:error, message) |> push_navigate(to: url)}
  end

  defp check_attempt_duration(socket) do
    attempt = socket.assigns.attempt

    if ends_at = attempt.ended_at do
      ends_after = DateTime.diff(ends_at, DateTime.utc_now(), :second)

      if ends_after < 0 do
        push_navigate(socket, to: ~p"/exams/#{attempt}/result")
      else
        Process.send_after(self(), :wrap_up, :timer.seconds(ends_after))
        assign(socket, ends_after: ends_after, ends_at: ends_at)
      end
    else
      socket
    end
  end

  defp page_title(attempt, order) do
    task = gettext("Task")
    order_in_title = to_string(order + 1)
    "#{task} №#{order_in_title} · #{attempt.test.title}"
  end

  defp restore_new_lines(text) do
    text
    |> String.split("\n", trim: false)
    |> Enum.intersperse(Phoenix.HTML.Tag.tag(:br))
  end

  defp format_remaining_time(seconds) do
    [div(seconds, 60), rem(seconds, 60)]
    |> Enum.map(&add_leading_zero/1)
    |> Enum.join(":")
  end

  defp add_leading_zero(time) do
    time
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp notify_answer(socket, answer) do
    %{attempt: attempt, current_user: user} = socket.assigns
    Proctoring.notify_proctor(attempt.test.id, {:answer, user.id, answer})

    socket
  end

  defp notify_wrap_up(socket) do
    %{attempt: attempt, current_user: user} = socket.assigns
    Proctoring.notify_proctor(attempt.test.id, {:wrap_up, user.id})

    socket
  end

  defp notify_open_task(socket) do
    %{attempt: attempt, current_user: user, order: order} = socket.assigns
    Proctoring.notify_proctor(attempt.test.id, {:open_task, user.id, order})

    socket
  end
end
