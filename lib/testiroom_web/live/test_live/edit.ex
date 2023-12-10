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
    {:noreply,
     socket
     |> assign(:page_title, gettext("Edit Test"))
     |> assign(:test, Exams.get_test!(id))}
  end
end
