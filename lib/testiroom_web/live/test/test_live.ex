defmodule TestiroomWeb.TestLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tests: Exams.list_tests())}
  end
end
