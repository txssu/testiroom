defmodule TestiroomWeb.TestsLive do
  alias Testiroom.Exams
  use TestiroomWeb, :live_view

  def render(assigns) do
    ~H"""
    <ul>
      <li :for={test <- @tests}>
        <%= test.title %>
        <.link class="phx-submit-loading:opacity-75 py-4 px-8 rounded-2xl text-inkdark font-medium btn-primary inline-block w-fit" navigate={~p"/tests/#{test}/exam"}>Перейти</.link>
      </li>
    </ul>

    <.link class="phx-submit-loading:opacity-75 py-4 px-8 rounded-2xl text-inkdark font-medium btn-primary inline-block w-fit" navigate={~p"/tests/create"}>Создать тест</.link>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tests: Exams.list_tests())}
  end
end
