defmodule Testiroom.Exams.AttemptManager do
  use GenServer

  alias Testiroom.Exams.StudentAttempt

  def get_task_and_answer(attempt, index) do
    GenServer.call(attempt, {:get_task_and_answer, index})
  end

  def answer_task(attempt, index, answer) do
    GenServer.call(attempt, {:answer_task, index, answer})
  end

  def wrap_up(attempt) do
    GenServer.call(attempt, :wrap_up)
  end

  @impl true
  def init({user, student_attempt}) do
    {:ok, {user, student_attempt}}
  end

  @impl true
  def handle_call({:get_task_and_answer, index}, _from, {_user, student_attempt} = state) do
    task = StudentAttempt.get_task(student_attempt, index)
    answer = StudentAttempt.get_answer(student_attempt, index)
    {:reply, {task, answer}, state}
  end

  @impl true
  def handle_call({:answer_task, index, answer}, _from, {user, student_attempt}) do
    student_attempt = StudentAttempt.answer_task(student_attempt, index, answer)
    {:reply, :ok, {user, student_attempt}}
  end

  @impl true
  def handle_call(:wrap_up, _from, {_user, student_attempt} = state) do
    {:stop, :normal, student_attempt, state}
  end
end
