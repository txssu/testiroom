defmodule TestiroomWeb.CreateTestLive do
  alias TestiroomWeb.TaskForm
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="create">
      <.input field={@form[:title]} label="Название теста" />
      <fieldset phx-feedback-for={@form[:options].name}>
        <.inputs_for :let={task_form} field={@form[:tasks]}>
          <.live_component id={System.unique_integer()} module={TaskForm} form={task_form} />
        </.inputs_for>
        <.button type="button" phx-click="add-task">Добавить вопрос</.button>
        <.input_error field={@form[:tasks]} />
      </fieldset>
      <:actions>
        <.button>Создать</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    test = Exams.new_test()
    changeset = Exams.change_test(test)

    socket =
      socket
      |> assign(test: test, changeset: changeset)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("add-task", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_change(changeset, :tasks) || []
        changeset = Ecto.Changeset.put_change(changeset, :tasks, existing ++ [Exams.new_task()])
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("create", %{"test" => test_params}, socket) do
    case Exams.create_test(test_params) do
      {:ok, _test} ->
        socket =
          socket
          |> put_flash(:info, "Тест успешно создан")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_info({TaskForm, task_changeset, index}, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        original_tasks = Ecto.Changeset.get_change(changeset, :tasks)

        changed_tasks =
          if not Ecto.Changeset.get_change(task_changeset, :delete, false) ||
               task_changeset.data.id do
            List.update_at(original_tasks, index, fn _changeset -> task_changeset end)
          else
            List.delete_at(original_tasks, index)
          end

        changeset = Ecto.Changeset.put_change(changeset, :tasks, changed_tasks)
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  defp assign_form(socket, changeset) do
    assign(socket,
      form: to_form(changeset)
    )
  end
end
