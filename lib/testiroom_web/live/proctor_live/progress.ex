defmodule TestiroomWeb.ProctorLive.Progress do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Proctoring

  @impl Phoenix.LiveView
  def mount(%{"test_id" => id}, _session, socket) do
    test = Exams.get_test!(id)

    Proctoring.register_proctor(id)

    {:ok, assign_pubsub_data(socket, test)}
  end

  @impl Phoenix.LiveView
  def handle_info({:proctoring, event}, socket) do
    {:noreply, handle_proctoring(event, socket)}
  end

  def handle_proctoring({:started, user, answers}, socket) do
    ordered_answers = Map.new(answers, &{&1.order, &1})

    socket
    |> update(:started_count, &(&1 + 1))
    |> update(:users, &[user | &1])
    |> update(:answers, &Map.put(&1, user.id, ordered_answers))
  end

  def handle_proctoring({:open_task, user_id, order}, socket) do
    event = Proctoring.Event.new_open_task(user_id, order, DateTime.utc_now())

    update(socket, :opens_history, &[event | &1])
  end

  def handle_proctoring({:answer, user_id, answer}, socket) do
    update(socket, :answers, &update_user_answer(&1, user_id, answer.task.order, answer))
  end

  def handle_proctoring({:wrap_up, user_id}, socket) do
    event = Proctoring.Event.new_wrap_up(user_id, DateTime.utc_now())

    socket |> update(:ended_count, &(&1 + 1)) |> update(:opens_history, &[event | &1])
  end

  defp assign_pubsub_data(socket, test) do
    socket
    |> assign(:test, test)
    |> assign(:tasks_count, Exams.get_max_task_order(test.id) + 1)
    |> assign(:users, [])
    |> assign(:started_count, 0)
    |> assign(:ended_count, 0)
    |> assign(:answers, %{})
    |> assign(:average_task_completion_time, 0)
    |> assign(:opens_history, [])
  end

  defp time_per_task(opens_history) do
    opens_history
    |> Enum.group_by(& &1.user_id)
    |> Enum.map(fn {_user_id, events} -> calculate_spended_time(events) end)
    |> Enum.reduce(%{}, fn spended_time, acc ->
      Map.merge(acc, spended_time, fn _key, a, b -> a + b end)
    end)
  end

  defp calculate_spended_time(events) do
    events
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&calculate_task_spended_time/1)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {order, time_list} -> {order, Enum.sum(time_list)} end)
  end

  def calculate_task_spended_time([a, b] = _events) do
    {b.order, DateTime.diff(a.datetime, b.datetime, :millisecond)}
  end

  defp average_all_tasks_answer_time(opens_history, tasks_count, started_count) do
    time =
      opens_history
      |> time_per_task()
      |> Enum.reduce(0, fn {_order, time}, acc -> time + acc end)
      |> Kernel./(tasks_count)
      |> Kernel./(started_count)
      |> Kernel./(1000)
      |> round()

    minutes = div(time, 60)
    seconds = rem(time, 60)
    "#{minutes}:#{seconds}"
  end

  def update_user_answer(answers, user_id, order, answer) do
    Map.update(answers, user_id, %{order => answer}, fn user_answers ->
      Map.put(user_answers, order, answer)
    end)
  end

  defp get_passing_rate(_answers, _tasks_count, 0) do
    0
  end

  defp get_passing_rate(answers, tasks_count, started_count) do
    answers_count =
      answers
      |> Enum.map(fn {_user, answers} ->
        Enum.count(answers, fn {_order, answer} -> StudentAnswer.correct?(answer) end)
      end)
      |> Enum.sum()

    round(answers_count / tasks_count / started_count * 100)
  end

  def get_ratio(answers, user_id) do
    {scores, max_scores} =
      answers
      |> Map.get(user_id, [])
      |> Enum.map(fn {_order, answer} -> StudentAnswer.get_score(answer) end)
      |> Enum.unzip()

    if scores == [] do
      0
    else
      Enum.sum(scores) / Enum.sum(max_scores) * 100
    end
  end

  def get_grade(answers, user_id, test) do
    ratio = get_ratio(answers, user_id)

    test.grades
    |> Enum.find(fn grade -> ratio >= grade.from end)
    |> Map.fetch!(:grade)
  end

  defp get_last_opened_order(opens_history, user_id) do
    last_event = Enum.find(opens_history, fn event -> event.user_id == user_id end)

    last_event && last_event.order
  end

  defp correctness_color(answer) do
    if StudentAnswer.answer_given?(answer) do
      if StudentAnswer.correct?(answer),
        do: "bg-correct",
        else: "bg-incorrect"
    end
  end

  defp correct_answers_ratio(answers) do
    answers
    |> Enum.reduce(%{}, fn {_user_id, user_answers}, acc ->
      user_answers
      |> Map.new(fn {order, answer} -> {order, StudentAnswer.get_score(answer)} end)
      |> Map.merge(acc, fn _key, a, b -> pair_plus(a, b) end)
    end)
    |> Map.new(fn {key, {score, max_score}} ->
      ratio =
        if max_score == 0 do
          0
        else
          score / max_score
        end

      {key, round(ratio * 100)}
    end)
  end

  defp pair_plus({a, b}, {c, d}), do: {a + c, b + d}

  slot :inner_block, required: true

  defp column(assigns) do
    ~H"""
    <td class="relative p-0">
      <div class="block py-4 pr-6">
        <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
        <span class="relative">
          <%= render_slot(@inner_block) %>
        </span>
      </div>
    </td>
    """
  end
end
