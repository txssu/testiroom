defmodule TestiroomWeb.TestListLive do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  def render(assigns) do
    ~H"""
    <.table id="tests" rows={@tests} row_click={fn test -> JS.navigate(~p"/tests/#{test}/exam") end}>
      <:col :let={test} label={gettext("Title")}><%= test.title %></:col>
      <:col :let={test} label={gettext("Starts at")}>
        <span id={"test-#{test.id}-starts-at"} phx-hook="DateTimeWithTZSetter" data-datetime={test.starts_at}>
          <%= test.starts_at %>
        </span>
      </:col>
      <:col :let={test} label={gettext("Ends at")}>
        <span id={"test-#{test.id}-ends-at"} phx-hook="DateTimeWithTZSetter" data-datetime={test.ends_at}>
          <%= test.ends_at %>
        </span>
      </:col>
    </.table>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tests, Exams.list_tests())}
  end
end
