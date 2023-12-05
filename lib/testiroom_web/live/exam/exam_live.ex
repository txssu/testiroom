defmodule TestiroomWeb.ExamLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  alias TestiroomWeb.AnswerTextForm
  alias TestiroomWeb.AnswerOptionsForm

  def mount(%{"id" => test_id}, %{"anonymous_identity" => user_id}, socket) do
    user = %{id: user_id}
    test = Exams.get_test(test_id)
    {:ok, assign(socket, page_title: test.title, test: test, user: user)}
  end

  def handle_params(%{"index" => index}, _uri, socket) do
    %{user: user, test: test} = socket.assigns

    attempt =
      case Map.fetch(socket.assigns, :attempt) do
        :error ->
          {user.id, test.id}

        {:ok, attempt} ->
          attempt
      end

    if Exams.attempt_started?(attempt) do
      count = Exams.get_tasks_count(attempt)

      index =
        index
        |> String.to_integer()
        |> min(count)
        |> max(0)

      {task, answer, done_status} = Exams.get_task_and_answer(attempt, index)
      answer = answer || Exams.StudentAnswer.new()

      ends_after = start_timer(test, attempt)

      {:noreply,
       assign(socket,
         attempt: attempt,
         current_task: task,
         current_answer: answer,
         current_index: index,
         tasks_count: count,
         done_status: done_status,
         ends_after: ends_after
       )}
    else
      {:noreply, push_patch(socket, to: ~p"/tests/#{test}/exam")}
    end
  end

  def handle_params(_params, _uri, socket) do
    %{user: user, test: test} = socket.assigns

    attempt =
      case Map.fetch(socket.assigns, :attempt) do
        :error ->
          {user.id, test.id}

        {:ok, attempt} ->
          attempt
      end

    if Exams.attempt_started?(attempt) do
      {:noreply, push_patch(socket, to: ~p"/tests/#{test}/exam/0")}
    else
      {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("start", _params, socket) do
    %{user: user, test: test} = socket.assigns
    now = DateTime.now!("Etc/UTC") |> DateTime.add(5, :hour)

    if start_test?(test, now) do
      attempt_id = Exams.start_attempt(user, test)

      socket =
        socket
        |> assign(attempt_id: attempt_id)
        |> push_patch(to: ~p"/tests/#{test}/exam/0")

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "Этот тест закончился или ещё не начался")}
    end
  end

  def handle_event("wrap-up", _params, socket) do
    wrap_up(socket)
  end

  def handle_info(:wrap_up, socket) do
    wrap_up(socket)
  end

  def handle_info({:answer_form, answer}, socket) do
    %{attempt: attempt, current_index: index} = socket.assigns
    Exams.answer_task(attempt, index, answer)
    {:noreply, socket}
  end

  defp wrap_up(socket) do
    result = Exams.wrap_up_attempt(socket.assigns.attempt)

    answers = Enum.map(result.answers, &elem(&1, 1))

    {:ok, inserted_results} = Exams.insert_answers(answers)

    socket = redirect(socket, to: ~p"/results/#{inserted_results}")

    {:noreply, socket}
  end

  defp form_module(:text), do: AnswerTextForm
  defp form_module(type) when type in [:radio, :checkbox], do: AnswerOptionsForm

  defp start_test?(test, now) do
    test_started?(test, now) and not test_ended?(test, now)
  end

  defp test_started?(test, now) do
    if test.starts_at do
      DateTime.before?(test.starts_at, now)
    else
      true
    end
  end

  defp test_ended?(test, now) do
    if test.ends_at do
      DateTime.before?(test.ends_at, now)
    else
      false
    end
  end

  defp start_timer(test, attempt) do
    if test.duration_in_minutes do
      attempt_started_at = Exams.get_started_at(attempt)

      attempt_ends_at = DateTime.add(attempt_started_at, test.duration_in_minutes, :minute)

      now = DateTime.now!("Etc/UTC") |> DateTime.add(5, :hour)

      time_to_end_in_seconds = DateTime.diff(attempt_ends_at, now, :second)

      Process.send_after(self(), :wrap_up, :timer.seconds(time_to_end_in_seconds))

      time_to_end_in_seconds
    end
  end

  def review(assigns) do
    ~H"""
    <ul class="flex gap-2.5 flex-wrap mb-16 w-auto">
      <li :for={{order, done?} <- Enum.zip(1..@tasks_count, @done_status)}>
        <.link
          class={[
            "inline-block h-9 min-w-[36px] px-2 rounded-[12px]",
            cond do
              order - 1 == @current_index -> "border-2 border-primary"
              done? -> "bg-primary text-white"
              true -> "border-2 border-ink-gray"
            end
          ]}
          patch={~p"/tests/#{@test}/exam/#{order - 1}"}
        >
          <div class="flex h-full justify-center items-center">
            <%= order %>
          </div>
        </.link>
      </li>
    </ul>
    <.button class="btn-primary w-full" phx-click="wrap-up">Закончить тест</.button>
    """
  end

  defp datetime(assigns) do
    assigns =
      assign(assigns, :formatted_datetime, Calendar.strftime(assigns.datetime, "%H:%M %d.%m.%Y"))

    ~H"""
    <%= @formatted_datetime %>
    """
  end
end
