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

  def render_body(%{status: :ended} = assigns) do
    ~H"""
    <div :for={answer <- @results} class="mb-3">
      <%= render_result(assign(assigns, :answer, answer)) %>
    </div>
    """
  end

  def render_result(%{answer: %{task: %{type: :shortanswer}}} = assigns) do
    ~H"""
    <div><%= @answer.task.question %></div>
    <%= if @answer.text do %>
      <div>Ваш ответ: <%= @answer.text %></div>
    <% else %>
      <div>Нет ответа</div>
    <% end %>
    <div>
      <%= if @answer.task.answer == @answer.text do %>
        Верно!
      <% else %>
        Неверно! Правильный ответ - <%= @answer.task.answer %>
      <% end %>
    </div>
    """
  end

  def render_result(%{answer: %{task: %{type: type}}} = assigns) when type in ~w[multiple single]a do
    ~H"""
    <div><%= @answer.task.question %></div>
    <div>
      <div>Вы выбрали:</div>
      <div>
        <ul>
          <li :for={option <- @answer.selected_task_options}><%= option.text %></li>
        </ul>
      </div>
      <div>Правильный ответ:</div>
      <div>
        <ul>
          <li :for={option <- Enum.filter(@answer.task.options, & &1.is_correct)}>
            <%= option.text %>
          </li>
        </ul>
      </div>
    </div>
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
    results =
      socket.assigns.answers
      |> map_to_ordered_list()
      |> Enum.map(fn {_order, answer} -> Exams.create_student_answer(answer) end)

    {:noreply, assign(socket, status: :ended, results: results)}
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
