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

  def render(%{status: :pending} = assigns) do
    ~H"""
    <div class="px-12 py-9 max-w-lg m-auto">
      <h1 class="text-2xl mb-4"><%= @test.title %></h1>
      <.button class="btn-primary" phx-click="start">Начать</.button>
    </div>
    """
  end

  def render(%{status: :started} = assigns) do
    ~H"""
    <div class="h-screen px-12 py-9 flex lg:grid lg:grid-cols-[320px_minmax(0px,672px)_320px] justify-center">
      <div class="hidden lg:block"></div>
      <div class="flex-1 h-full w-full flex flex-col justify-between max-w-2xl">
        <div class="text-2xl leading-8 font-medium">
          <%= @answers[@current_order].task.question %>
        </div>
        <.live_component id="answer-form" module={AnswerForm} answer={@answers[@current_order]} />
        <div class="flex flex-col gap-2.5">
          <div class="text-center leading-7"><%= @current_order + 1 %> из <%= @count %></div>
          <div class="flex gap-2.5">
            <.previous_task_button current_order={@current_order} />
            <.next_task_button current_order={@current_order} count={@count} />
          </div>
          <div class="flex lg:hidden">
            <.button class="btn-primary" phx-click={show_modal("review")}>Обзор</.button>
          </div>
        </div>
      </div>
      <div class="hidden lg:block float-right">
        <div class="border-2 border-inkgray p-8 rounded-[32px]">
          <.review answers={@answers} current_order={@current_order} count={@count} />
        </div>
      </div>
    </div>

    <.bottom_modal id="review">
      <.review answers={@answers} current_order={@current_order} count={@count} />
    </.bottom_modal>
    """
  end

  def review(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2.5 mb-16">
      <.page_button
        :for={{order, answer} <- map_to_ordered_list(@answers)}
        order={order}
        answer={answer}
        current={@current_order}
        count={@count}
      />
    </div>
    <.button class="btn-secondary" phx-click="end">Закончить тест</.button>
    """
  end

  def previous_task_button(assigns) do
    assigns =
      assign(
        assigns,
        :class,
        if assigns.current_order == 0 do
          "btn-seconday-inactive"
        else
          "btn-secondary"
        end
      )

    ~H"""
    <.button class={@class} phx-click="previous-task">Назад</.button>
    """
  end

  def next_task_button(assigns) do
    assigns =
      assign(
        assigns,
        :class,
        if assigns.current_order + 1 == assigns.count do
          "btn-seconday-inactive"
        else
          "btn-secondary"
        end
      )

    ~H"""
    <.button class={@class} phx-click="next-task">Далее</.button>
    """
  end

  def page_button(assigns) do
    assigns =
      assign(
        assigns,
        :class,
        cond do
          assigns.answer.text || assigns.answer.selected_options != [] -> "bg-primary text-white"
          assigns.current == assigns.order -> "border-2 border-primary"
          true -> "border-2 border-inkgray"
        end
      )

    ~H"""
    <button
      class={[
        "flex items-center justify-center h-9 min-w-[36px] p-y-[5px] rounded-[12px] text-color",
        @class
      ]}
      phx-click="goto"
      phx-value-order={@order}
    >
      <%= @order + 1 %>
    </button>
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

    {:noreply,
     assign(socket,
       status: :started,
       answers: answers,
       current_order: 0,
       count: Enum.count(answers)
     )}
  end

  def handle_event("next-task", _params, socket) do
    {:noreply,
     update(socket, :current_order, fn order ->
       if order + 1 == socket.assigns.count do
         order
       else
         order + 1
       end
     end)}
  end

  def handle_event("previous-task", _params, socket) do
    {:noreply,
     update(socket, :current_order, fn order ->
       if order == 0 do
         0
       else
         order - 1
       end
     end)}
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
