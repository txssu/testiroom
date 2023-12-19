defmodule TestiroomWeb.ExamLive.Start do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  @impl Phoenix.LiveView
  def mount(%{"test_id" => test_id}, _session, socket) do
    test = Exams.get_test!(test_id)

    {:ok, socket |> assign(:test, test) |> assign(:page_title, test.title)}
  end

  @impl Phoenix.LiveView
  def handle_event("start", _unsigned_params, socket) do
    %{current_user: user, test: test} = socket.assigns
    now = DateTime.utc_now()

    if DateTime.after?(now, test.starts_at) and DateTime.before?(now, test.ends_at) do
      {:ok, attempt} = Exams.start_attempt(user, test)

      {:noreply, push_navigate(socket, to: ~p"/exams/#{attempt}/0")}
    else
      {:noreply, put_flash(socket, :error, gettext("This test is over or hasn't started yet"))}
    end
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%H:%M %d.%m.%Y")
  end
end