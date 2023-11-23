defmodule TestiroomWeb.TestFormLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.Test
  alias TestiroomWeb.TaskForm

  @impl true
  def mount(params, %{"anonymous_identity" => user_id}, socket) do
    action = socket.assigns.live_action

    test =
      case action do
        :new -> Test.new(author_id: user_id)
        :edit -> Exams.get_test(params["id"])
      end

    if test.author_id == user_id do
      changeset = Test.changeset(test, %{})

      socket =
        socket
        |> assign(test: test, page_title: get_page_title(action))
        |> assign_form(changeset)
        |> allow_tasks_uploads()

      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "Вы не являетесь создателем этого теста")
        |> redirect(to: ~p"/tests")

      {:ok, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign_form(changeset)
      |> allow_tasks_uploads()

    {:noreply, socket}
  end

  def handle_event("create", %{"test" => test_params}, socket) do
    params =
      socket
      |> upload_files()
      |> insert_files_to_params(test_params)
      |> IO.inspect()

    insert_test(socket.assigns.live_action, params, socket)
  end

  defp insert_test(action, params, socket)

  defp insert_test(:new, params, socket) do
    case Exams.create_test(socket.assigns.test, params) do
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

  defp insert_test(:edit, params, socket) do
    case Exams.update_test(socket.assigns.test, params) do
      {:ok, test} ->
        socket =
          socket
          |> put_flash(:info, "Тест успешно обновлён")
          |> push_navigate(to: ~p"/tests/#{test}/exam")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket,
      form: to_form(changeset)
    )
  end

  defp get_page_title(:new), do: "Создание теста"
  defp get_page_title(:edit), do: "Редактирование теста"

  defp task_upload_names(socket) do
    tasks_field = socket.assigns.form[:tasks]

    tasks = tasks_field.value
    task_name = tasks_field.name

    tasks
    |> Stream.with_index()
    |> Stream.map(fn {_task, index} -> "#{task_name}[#{index}]" end)
  end

  defp reject_allowed(uploads, socket) do
    allowed_uploads = Map.get(socket.assigns, :uploads, %{})

    Enum.reject(uploads, fn name -> name in Map.keys(allowed_uploads) end)
  end

  defp allow_tasks_uploads(socket) do
    socket
    |> task_upload_names()
    |> reject_allowed(socket)
    |> Enum.reduce(socket, &allow_upload(&2, &1, accept: ~w(.jpg .jpeg), max_entries: 1))
  end

  defp upload_files(socket) do
    socket
    |> task_upload_names()
    |> Enum.map(
      &consume_uploaded_entries(socket, &1, fn %{path: path}, entry ->
        dest = Path.join([:code.priv_dir(:testiroom), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)
        {:ok, %{form_name: entry.upload_config, path: ~p"/uploads/#{Path.basename(dest)}"}}
      end)
    )
    |> Enum.reduce(%{}, fn entries, result ->
      %{form_name: form_name} = List.first(entries)
      Map.put(result, form_name, entries)
    end)
  end

  defp insert_files_to_params(files, params) do
    params
    |> Map.update!("tasks", fn tasks ->
      Enum.into(tasks, %{}, fn {key, task} ->
        {key, Map.put(task, "media", files["test[tasks][#{key}]"])}
      end)
    end)
  end
end
