defmodule TestiroomWeb.TestsLive do
  alias Testiroom.Exams
  use TestiroomWeb, :live_view

  def render(assigns) do
    ~H"""
    <ul>
      <li :for={test <- @tests}>
        <.link navigate={~p"/tests/#{test}/exam"}><%= test.title %></.link>
      </li>
    </ul>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tests: Exams.list_tests())}
  end
end
