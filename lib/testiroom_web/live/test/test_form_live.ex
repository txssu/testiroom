defmodule TestiroomWeb.TestFormLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.Test
  alias TestiroomWeb.TaskForm

  @impl true
  def mount(_params, _session, socket) do
    test =
      Test.new()

    form =
      test
      |> Test.changeset(%{})
      |> to_form()

    socket = assign(socket, form: form, test: test)
    {:ok, socket}
  end

  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("create", %{"add-task" => _value, "test" => test_params}, socket) do
    test_params =
      Map.update(test_params, "tasks", %{"0" => %{}}, fn tasks ->
        id =
          tasks
          |> Enum.max_by(fn {id, _task} ->
            String.to_integer(id)
          end)
          |> elem(0)
          |> String.to_integer()
          |> Kernel.+(1)
          |> to_string()

        Map.put(tasks, id, %{})
      end)

    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("create", %{"add-option" => task_index, "test" => test_params}, socket) do
    test_params =
      Map.update!(
        test_params,
        "tasks",
        &Map.update!(
          &1,
          task_index,
          fn task ->
            Map.update(task, "options", %{"0" => %{}}, fn options ->
              id = fetch_next_id(options)

              Map.put(options, id, %{})
            end)
          end
        )
      )

    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("create", %{"test" => test_params}, socket) do
    case Exams.create_test(test_params) do
      {:ok, test} ->
        socket =
          socket
          |> put_flash(:info, "Тест успешно создан")
          |> push_navigate(to: ~p"/tests/#{test}/exam")

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

  defp fetch_next_id(map) do
    map
    |> Enum.max_by(fn {id, _value} ->
      String.to_integer(id)
    end)
    |> elem(0)
    |> String.to_integer()
    |> Kernel.+(1)
    |> to_string()
  end
end
