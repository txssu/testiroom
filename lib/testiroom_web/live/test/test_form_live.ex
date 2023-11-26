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

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("create", %{"test" => test_params}, socket) do
    insert_test(socket.assigns.live_action, test_params, socket)
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
end
