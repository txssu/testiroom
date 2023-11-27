defmodule TestiroomWeb.Live.Dashboard.TestNew do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.Test

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    changeset = Exams.change_test(%Test{})
    socket = socket |> assign(:page_title, "New test") |> assign(:form, to_form(changeset))
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      %Test{}
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"test" => test_params}, socket) do
    case Exams.create_test(test_params) do
      {:ok, test} -> {:noreply, push_navigate(socket, to: ~p"/tests/#{test}/edit")}
      {:error, changeset} -> {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
