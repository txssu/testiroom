defmodule TestiroomWeb.TestLive.Index do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Exams.Test

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    {:ok, stream(socket, :tests, Exams.list_user_tests(user.id))}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"test_id" => id}) do
    socket
    |> assign(:page_title, "Edit Test")
    |> assign(:test, Exams.get_test!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Test")
    |> assign(:test, %Test{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tests")
    |> assign(:test, nil)
  end

  @impl Phoenix.LiveView
  def handle_info({TestiroomWeb.TestLive.FormComponent, {:saved, test}}, socket) do
    {:noreply, stream_insert(socket, :tests, test)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    test = Exams.get_test!(id)
    {:ok, _} = Exams.delete_test(test)

    {:noreply, stream_delete(socket, :tests, test)}
  end
end
