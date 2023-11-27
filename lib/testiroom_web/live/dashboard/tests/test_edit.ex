defmodule TestiroomWeb.Live.Dashboard.TestEdit do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Dashboard.Components.Menu

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(%{"test_id" => test_id}, _session, socket) do
    test = Exams.get_test!(test_id)
    changeset = Exams.change_test(test)

    socket =
      socket
      |> assign(:page_title, "Edit test")
      |> assign(:test, test)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"test" => test_params}, socket) do
    test = socket.assigns.test

    case Exams.update_test(test, test_params) do
      {:ok, test} ->
        socket =
          socket
          |> assign(:test, test)
          |> put_flash(:info, gettext("Saved"))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
