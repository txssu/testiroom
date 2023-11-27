defmodule TestiroomWeb.Live.Dashboard.TaskList do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Dashboard.Components.Menu

  alias Testiroom.Exams

  def mount(%{"test_id" => test_id}, _session, socket) do
    max_order = Exams.get_max_task_order(test_id)

    next_order =
      case max_order do
        nil -> 0
        value -> value + 1
      end

    socket =
      socket
      |> assign(:page_title, gettext("Tasks"))
      |> assign(:test_id, test_id)
      |> assign(:max_order, max_order)
      |> assign(:next_order, next_order)

    {:ok, socket}
  end

  def handle_params(%{"test_id" => test_id, "order" => order}, _uri, socket) do
    socket =
      socket
      |> assign(:tasks, Exams.list_tasks_by_order(test_id, order))
      |> assign(:current_order, String.to_integer(order))

    {:noreply, socket}
  end

  def handle_event("add-task", _params, socket) do
    %{test_id: test_id, current_order: current_order} = socket.assigns

    attrs = %{"order" => current_order, "question" => gettext("Empty question"), "test_id" => test_id}

    case Exams.create_task(attrs) do
      {:ok, _task} ->
        {:noreply, push_patch(socket, to: ~p"/tests/#{test_id}/tasks/o/#{current_order}")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Could not add task!"))}
    end
  end
end
