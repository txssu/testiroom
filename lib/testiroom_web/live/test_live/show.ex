defmodule TestiroomWeb.TestLive.Show do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"test_id" => id}, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:test, Exams.get_test!(id))}
  end

  defp page_title(:show), do: "Show Test"
  defp page_title(:edit), do: "Edit Test"
end
