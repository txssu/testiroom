defmodule TestiroomWeb.TestLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Все тесты", tests: Exams.list_tests())}
  end
end
