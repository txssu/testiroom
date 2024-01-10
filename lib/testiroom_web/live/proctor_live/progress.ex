defmodule TestiroomWeb.ProctorLive.Progress do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Proctoring
  alias Testiroom.Proctoring.Monitor

  @impl Phoenix.LiveView
  def mount(%{"test_id" => id}, _session, socket) do
    test = Exams.get_test!(id)

    max_task_order = Exams.get_max_task_order(id)

    Proctoring.register_proctor(id)

    {:ok,
     socket
     |> assign(:test, test)
     |> assign(:monitor, %Monitor{})
     |> assign(:max_task_order, max_task_order)
     |> assign(:tasks_count, max_task_order + 1)}
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

  defp format_millisecodns(milliseconds) do
    total_seconds = div(milliseconds, 1000)
    seconds = total_seconds |> rem(60) |> add_leading_zero()
    minutes = total_seconds |> div(60) |> add_leading_zero()

    "#{minutes}:#{seconds}"
  end

  defp add_leading_zero(time) do
    time
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
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
