defmodule TestiroomWeb.ExamResultLive do
  alias Testiroom.Exams
  use TestiroomWeb, :live_view

  def render(assigns) do
    ~H"""
    <div :for={answer <- @result.student_answers} class="mb-3">
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

  def render_result(%{answer: %{task: %{type: type}}} = assigns)
      when type in ~w[multiple single]a do
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

  def mount(%{"id" => result_id}, _session, socket) do
    result = Exams.get_result(result_id)
    {:ok, assign(socket, result: result)}
  end
end
