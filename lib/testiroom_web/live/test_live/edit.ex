defmodule TestiroomWeb.TestLive.Edit do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Components.TestEditorHeader

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"test_id" => id}, _uri, socket) do
    test = Exams.get_test!(id)

    if test.user_id == socket.assigns.current_user.id do
      {:noreply,
       socket
       |> assign(:page_title, gettext("Edit Test"))
       |> assign(:test, test)}
    else
      {:noreply,
       socket
       |> put_flash(:error, gettext("You cannot edit other users' tests."))
       |> push_navigate(to: ~p"/tests")}
    end
  end
end
