defmodule TestiroomWeb.TaskLive.Show do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"test_id" => test_id, "task_id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:test_id, test_id)
     |> assign(:task, Exams.get_task!(id))}
  end

  defp page_title(:show), do: "Show Task"
  defp page_title(:edit), do: "Edit Task"
end
