defmodule TestiroomWeb.ProctorLive.Progress do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Proctoring
  alias Testiroom.Proctoring.Monitor

  @impl Phoenix.LiveView
  def mount(%{"test_id" => id}, _session, socket) do
    test = Exams.get_test!(id)
    monitor = Proctoring.get_monitor(id)

    max_task_order = Exams.get_max_task_order(id)

    case Proctoring.register_proctor(id) do
      {:ok, _pid} ->
        {:ok,
         socket
         |> assign(:test, test)
         |> assign(:monitor, monitor)
         |> assign(:max_task_order, max_task_order)
         |> assign(:tasks_count, max_task_order + 1)}

      {:error, _error} ->
        {:ok,
         socket
         |> put_flash(:error, gettext("Currently you cannot open the monitoring page in multiple tabs"))
         |> push_navigate(to: ~p"/tests/")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:proctoring, event}, socket) do
    {:noreply, update(socket, :monitor, &Monitor.handle(&1, event))}
  end

  def format_time_per_task(%Monitor{spended_time_per_task: spended_time, started_counter: started}, tasks_count) do
    milliseconds =
      if started == 0 do
        0
      else
        spended_time
        |> Map.values()
        |> Enum.sum()
        |> div(tasks_count * started)
      end

    format_millisecodns(milliseconds)
  end

  defp format_time_by_tasks(%Monitor{spended_time_per_task: spended_time, started_counter: started}, max_task_order) do
    milliseconds =
      if started == 0 do
        Stream.map(0..max_task_order, fn _order -> 0 end)
      else
        Stream.map(0..max_task_order, &div(Map.get(spended_time, &1, 0), started))
      end

    Enum.map(milliseconds, &format_millisecodns/1)
  end

  defp format_millisecodns(milliseconds) do
    total_seconds = div(milliseconds, 1000)
    seconds = total_seconds |> rem(60) |> add_leading_zero()
    minutes = total_seconds |> div(60) |> add_leading_zero()

    "#{minutes}:#{seconds}"
  end

  defp calculate_correctness_ratio_by_tasks(%Monitor{user_answers_correctness: correctness, started_counter: started}) do
    correctness
    |> Enum.reduce(%{}, fn {_user_id, correctnesses}, acc ->
      correctnesses
      |> Map.new(fn {key, value} -> {key, if(value, do: 1, else: 0)} end)
      |> Map.merge(acc, fn _key, a, b -> b + a end)
    end)
    |> Map.new(fn {key, value} -> {key, value / started} end)
  end

  defp get_grade(test, ratio) do
    percents = ratio_to_percents(ratio)

    test.grades
    |> Enum.find(fn grade -> percents >= grade.from end)
    |> Map.fetch!(:grade)
  end

  defp calculate_correctness_ratio_by_user(%Monitor{user_answers_correctness: correctness}, user_id, tasks_count) do
    correctness
    |> Map.get(user_id, %{})
    |> Enum.count(&elem(&1, 1))
    |> Kernel./(tasks_count)
  end

  defp ratio_to_percents(ratio) do
    round(ratio * 100)
  end

  defp add_leading_zero(time) do
    time
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  defp correctness_color(correct?)
  defp correctness_color(true), do: "bg-correct"
  defp correctness_color(false), do: "bg-incorrect"
  defp correctness_color(nil), do: ""

  defp cheating_outline(monitor, user_id) do
    if Map.get(monitor.maybe_cheating, user_id, false) do
      "border-2 border-incorrect"
    end
  end

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
