defmodule TestiroomWeb.Live.Dashboard.TaskView do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Dashboard.Components.Menu

  alias Testiroom.Exams
  alias TestiroomWeb.Live.Dashboard.Components.TaskForm

  @impl Phoenix.LiveView
  def mount(%{"test_id" => test_id, "task_id" => task_id}, _session, socket) do
    task = Exams.get_task!(test_id, task_id)

    socket =
      socket
      |> assign(:test_id, test_id)
      |> assign(:task, task)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    apply_action(socket.assigns.live_action, params, socket)
  end

  defp apply_action(:view, _params, socket) do
    {:noreply, socket}
  end

  defp apply_action(:edit, _params, socket) do
    changeset = Exams.change_task(socket.assigns.task)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl Phoenix.LiveView
  def handle_info({TaskForm, :update_task, task}, socket) do
    {:noreply, assign(socket, :task, task)}
  end
end
