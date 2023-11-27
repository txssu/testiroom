defmodule TestiroomWeb.Live.Dashboard.TestList do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    tests = Exams.list_tests()

    socket = socket |> assign(:page_title, gettext("Test list")) |> assign(:tests, tests)

    {:ok, assign(socket, tests: tests)}
  end
end
