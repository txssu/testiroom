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
      </.header>

      <.simple_form for={@form} id="task-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:order]} type="hidden" value={@order} />
        <.input field={@form[:type]} type="select" label={gettext("Type")} prompt={gettext("Choose a type")} options={Exams.Task.types()} />
        <.input field={@form[:question]} type="textarea" label={gettext("Question")} />
        <fieldset phx-feedback-for={@form[:options].name}>
          <legend class="block text-sm font-semibold leading-6 text-zinc-800"><%= gettext("Options") %></legend>
          <div class="space-y-2">
            <.inputs_for :let={option} field={@form[:options]}>
              <div>
                <input type="hidden" name="task[options_order][]" value={option.index} />
                <div class="mb-2 flex flex-col gap-4 sm:flex-row">
                  <div class="flex-grow">
                    <.input field={option[:text]} type="text" />
                  </div>
                  <%= if Ecto.Changeset.get_field(@form.source, :type) == :text do %>
                    <div class="hidden">
                      <.input field={option[:is_correct]} type="checkbox" />
                    </div>
                  <% else %>
                    <div class="mt-0 sm:mt-4">
                      <.input field={option[:is_correct]} type="checkbox" label={gettext("Correct answer")} />
                    </div>
                  <% end %>
                </div>
                <.button class="mt-2" tag={:label} name="task[options_delete][]" value={option.index}>
                  <%= gettext("Delete") %>
                </.button>
              </div>
            </.inputs_for>
          </div>
          <.button tag={:label} name="task[options_order][]" class="mt-3">
            <%= gettext("Add option") %>
          </.button>
          <.error :for={msg <- Enum.map(@form[:options].errors, &translate_error/1)}>
            <%= msg %>
          </.error>
        </fieldset>
        <%= unless Ecto.Changeset.get_field(@form.source, :type) == :text do %>
        <.input field={@form[:shuffle_options]} type="checkbox" label={gettext("Shuffle options")} />
        <% end %>
        <.input field={@form[:score]} type="number" label={gettext("Score")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save Task") %></.button>
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
         |> put_flash(:info, gettext("Task updated successfully"))
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
         |> put_flash(:info, gettext("Task created successfully"))
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
