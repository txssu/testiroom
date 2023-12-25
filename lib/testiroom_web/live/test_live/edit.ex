defmodule TestiroomWeb.TestLive.Edit do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Components.TestEditorHeader

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(%{"test_id" => id}, _session, socket) do
    test = Exams.get_test!(id)

    if test.user_id == socket.assigns.current_user.id do
      {:ok,
       socket
       |> assign(:page_title, gettext("Edit Test"))
       |> assign(:test, test)}
    else
      {:ok,
       socket
       |> put_flash(:error, gettext("You cannot edit other users' tests."))
       |> push_navigate(to: ~p"/tests")}
    end
  end
end
