defmodule TestiroomWeb.TestLive.Edit do
  @moduledoc false
  use TestiroomWeb, :live_view

  import TestiroomWeb.Live.Components.TestEditorHeader

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(%{"test_id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Edit Test"))
     |> assign(:test, Exams.get_test!(id))}
  end
end
