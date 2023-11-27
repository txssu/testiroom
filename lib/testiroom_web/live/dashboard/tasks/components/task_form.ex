defmodule TestiroomWeb.Live.Dashboard.Components.TaskForm do
  @moduledoc false
  use TestiroomWeb, :live_component

  alias Testiroom.Exams
  alias Testiroom.Exams.Task

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input type="hidden" field={@form[:order]} />
        <.input type="select" field={@form[:type]} label={gettext("Task type")} options={Task.types()} prompt={gettext("Choose type")} prompt_selected={true} />
        <.input type="text" field={@form[:question]} label={gettext("Task text")} />
        <.input type="checkbox" field={@form[:shuffle_options]} label={gettext("Shuffle options")} />
        <.input type="number" field={@form[:score]} label={gettext("Score for correct answer")} />
        <:actions>
          <.button type="submit"><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{task: task, test_id: test_id}, socket) do
    changeset = Exams.change_task(task)

    socket =
      socket
      |> assign(:test_id, test_id)
      |> assign(:task, task)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Exams.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("save", %{"task" => task_params}, socket) do
    task = socket.assigns.task

    case Exams.update_task(task, task_params) do
      {:ok, task} ->
        notify_parent(task)

        socket =
          socket
          |> put_flash(:info, gettext("Saved"))
          |> push_patch(to: ~p"/tests/#{socket.assigns.test_id}/tasks/#{task}")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def notify_parent(task) do
    send(self(), {__MODULE__, :update_task, task})
  end
end
