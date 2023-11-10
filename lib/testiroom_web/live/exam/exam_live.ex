defmodule TestiroomWeb.ExamLive do
  use TestiroomWeb, :live_view

  alias Testiroom.Exams

  alias TestiroomWeb.AnswerForm

  @impl true
  def render(%{status: :loading} = assigns) do
    ~H"""
    Идёт загрузка...
    """
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl mb-4"><%= @test.title %></h1>
    <%= render_body(assigns) %>
    """
  end

  def render_body(%{status: :pending} = assigns) do
    ~H"""
    <.button phx-click="start">Начать</.button>
    """
  end

  def render_body(%{status: :started} = assigns) do
    ~H"""
    <div class="mb-4">
      <.button
        :for={{order, answer} <- map_to_ordered_list(@answers)}
        phx-click="goto"
        phx-value-order={order}
      >
        <%= order %>
        <%= if order == @current_order, do: "Текущий" %>
        <%= if answer.text || answer.selected_options != [], do: "Решён" %>
      </.button>
    </div>
    <.live_component id="answer-form" module={AnswerForm} answer={@answers[@current_order]} />
    <.button phx-click="end">Закончить тест</.button>
    """
  end

  @impl true
  @spec mount(any(), any(), Phoenix.LiveView.Socket.t()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    if connected?(socket) do
      test = Exams.get_test_by_title("Контрольная работа по математике №1")
      {:ok, assign(socket, status: :pending, test: test)}
    else
      {:ok, assign(socket, status: :loading)}
    end
  end

  @impl true
  def handle_event("start", _params, socket) do
    answers =
      Enum.into(socket.assigns.test.tasks, %{}, fn task ->
        {task.order, Exams.new_student_answer(task)}
      end)

    {:noreply, assign(socket, status: :started, answers: answers, current_order: 1)}
  end

  def handle_event("goto", %{"order" => order}, socket) do
    {:noreply, assign(socket, current_order: String.to_integer(order))}
  end

  def handle_event("end", _params, socket) do
    result =
      socket.assigns.answers
      |> Enum.map(fn {_order, answer} -> answer end)
      |> Exams.save_results(socket.assigns.test)

    {:noreply, push_navigate(socket, to: ~p"/results/#{result}")}
  end

  @impl true
  def handle_info({AnswerForm, answer}, socket) do
    order = socket.assigns.current_order

    answers = Map.put(socket.assigns.answers, order, answer)

    {:noreply, assign(socket, answers: answers)}
  end

  defp map_to_ordered_list(map) do
    map
    |> :maps.iterator(:ordered)
    |> :maps.to_list()
  end
end
