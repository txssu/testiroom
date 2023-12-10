defmodule TestiroomWeb.TaskLive.Index do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.Task

  import TestiroomWeb.Live.Components.TestEditorHeader

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"test_id" => test_id, "order" => order} = params, _url, socket) do
    {:noreply,
     socket
     |> assign(:test_id, test_id)
     |> assign(:max_order, Exams.get_max_task_order(test_id) || 0)
     |> assign(:order, String.to_integer(order))
     |> apply_action(socket.assigns.live_action, params)
     |> stream(:tasks, Exams.list_tasks(test_id, order), reset: true)}
  end

  defp apply_action(socket, :edit, %{"task_id" => id}) do
    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:test, nil)
    |> assign(:task, Exams.get_task!(id))
  end

  defp apply_action(socket, :new, %{"test_id" => test_id}) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:test, Exams.get_test!(test_id))
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, _params) do
    %{order: order, max_order: max_order, test_id: test_id} = socket.assigns

    if order <= max_order do
      socket
      |> assign(:page_title, "Listing Tasks")
      |> assign(:task, nil)
    else
      push_patch(socket, to: ~p"/tests/#{test_id}/tasks/#{max_order}")
    end
  end

  @impl Phoenix.LiveView
  def handle_info({TestiroomWeb.TaskLive.Components.TaskForm, {:saved, task}}, socket) do
    {:noreply, stream_insert(socket, :tasks, task)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    task = Exams.get_task!(id)
    {:ok, _} = Exams.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end
end
