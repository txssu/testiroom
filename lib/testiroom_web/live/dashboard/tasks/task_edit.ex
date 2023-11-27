defmodule TestiroomWeb.Live.Dashboard.TaskEdit do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Dashboard.Components.Menu

  alias Testiroom.Exams
  alias Testiroom.Exams.Task

  @impl Phoenix.LiveView
  def mount(%{"test_id" => test_id, "task_id" => task_id}, _session, socket) do
    task = Exams.get_task!(test_id, task_id)
    changeset = Exams.change_task(task)

    socket =
      socket
      |> assign(:test_id, test_id)
      |> assign(:task, task)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Exams.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"task" => task_params}, socket) do
    task = socket.assigns.task

    case Exams.update_task(task, task_params) do
      {:ok, _task} -> {:noreply, put_flash(socket, :info, gettext("Saved"))}
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
