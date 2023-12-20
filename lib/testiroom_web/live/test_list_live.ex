defmodule TestiroomWeb.TestListLive do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  def render(assigns) do
    ~H"""
    <.table id="tests" rows={@tests} row_click={fn test -> JS.navigate(~p"/tests/#{test}/exam") end}>
      <:col :let={test} label={gettext("Title")}><%= test.title %></:col>
      <:col :let={test} label={gettext("Starts at")}><%= test.starts_at %></:col>
      <:col :let={test} label={gettext("Ends at")}><%= test.ends_at %></:col>
    </.table>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tests, Exams.list_tests())}
  end
end
