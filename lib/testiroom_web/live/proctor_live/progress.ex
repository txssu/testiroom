defmodule TestiroomWeb.ProctorLive.Progress do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Exams
  alias Testiroom.Proctoring
  alias Testiroom.Proctoring.Monitor

  @impl Phoenix.LiveView
  def mount(%{"test_id" => id}, _session, socket) do
    test = Exams.get_test!(id)

    Proctoring.register_proctor(id)

    {:ok, socket |> assign(:test, test) |> assign(:monitor, %Monitor{})}
  end

  @impl Phoenix.LiveView
  def handle_info({:proctoring, event}, socket) do
    {:noreply, update(socket, :monitor, &Monitor.handle(&1, event))}
  end

  slot :inner_block, required: true

  defp column(assigns) do
    ~H"""
    <td class="relative p-0">
      <div class="block py-4 pr-6">
        <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
        <span class="relative">
          <%= render_slot(@inner_block) %>
        </span>
      </div>
    </td>
    """
  end
end
