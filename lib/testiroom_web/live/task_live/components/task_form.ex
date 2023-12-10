defmodule TestiroomWeb.TaskLive.Components.TaskForm do
  @moduledoc false
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage task records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="task-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:order]} type="hidden" value={@order} />
        <.input field={@form[:type]} type="select" label="Type" prompt="Choose a value" options={Ecto.Enum.values(Testiroom.Exams.Task, :type)} />
        <.input field={@form[:question]} type="text" label="Question" />
        <fieldset>
          <legend>Options</legend>
          <.inputs_for :let={option} field={@form[:options]}>
            <input type="hidden" name="task[options_order][]" value={option.index} />
            <.input field={option[:text]} type="text" label="Text" />
            <.input field={option[:is_correct]} type="checkbox" label="Is correct" />
            <label>
              <input type="checkbox" name="task[options_delete][]" value={option.index} class="hidden" /> Delete option
            </label>
          </.inputs_for>
          <label class="block cursor-pointer">
            <input type="checkbox" name="task[options_order][]" class="hidden" /> add more
          </label>
        </fieldset>
        <.input field={@form[:shuffle_options]} type="checkbox" label="Shuffle options" />
        <.input field={@form[:score]} type="number" label="Score" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Task</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent

  def update(%{task: task} = assigns, socket) do
    changeset = Exams.change_task(task)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Exams.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.action, task_params)
  end

  defp save_task(socket, :edit, task_params) do
    case Exams.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})

        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_task(socket, :new, task_params) do
    test = socket.assigns.test

    case Exams.create_task(task_params, test) do
      {:ok, task} ->
        notify_parent({:saved, task})

        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
