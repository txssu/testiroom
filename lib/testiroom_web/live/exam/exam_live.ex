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

    count = Exams.get_tasks_count(attempt)

    index =
      index
      |> String.to_integer()
      |> min(count)
      |> max(0)

    {task, answer, done_status} = Exams.get_task_and_answer(attempt, index)
    answer = answer || Exams.StudentAnswer.new()

    {:noreply,
     assign(socket,
       attempt: attempt,
       current_task: task,
       current_answer: answer,
       current_index: index,
       tasks_count: count,
       done_status: done_status
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("start", _params, socket) do
    %{user: user, test: test} = socket.assigns
    attempt_id = Exams.start_attempt(user, test)

    socket =
      socket
      |> assign(attempt_id: attempt_id)
      |> push_navigate(to: ~p"/tests/#{test}/exam/0")

    {:noreply, socket}
  end

  def handle_event("wrap-up", _params, socket) do
    result = Exams.wrap_up_attempt(socket.assigns.attempt)

    answers = Enum.map(result.answers, &elem(&1, 1))

    {:ok, inserted_results} = Exams.insert_answers(answers)

    socket = redirect(socket, to: ~p"/results/#{inserted_results}")

    {:noreply, socket}
  end

  def handle_info({:answer_form, answer}, socket) do
    %{attempt: attempt, current_index: index} = socket.assigns
    Exams.answer_task(attempt, index, answer)
    {:noreply, socket}
  end

  defp form_module(:text), do: AnswerTextForm
  defp form_module(type) when type in [:radio, :checkbox], do: AnswerOptionsForm

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
end
