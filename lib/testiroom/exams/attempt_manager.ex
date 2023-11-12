defmodule Testiroom.Exams.AttemptManager do
  use GenServer

  alias Testiroom.Exams.StudentAttempt

  def child_spec({user, student_attempt} = init_arg) do
    %{
      id: {__MODULE__, {student_attempt.test.id, user.id}},
      start: {__MODULE__, :start_link, [init_arg]},
      restart: :temporary
    }
  end

  def start_link({user, student_attempt} = init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: via({user.id, student_attempt.test.id}))
  end

  def start_attempt(user, student_attempt) do
    DynamicSupervisor.start_child(
      Testiroom.AttemptManager.Supervisor,
      {__MODULE__, {user, student_attempt}}
    )
  end

  def via({_user_id, _test_id} = id) do
    {
      :via,
      Registry,
      {Testiroom.AttemptManager.Registry, id}
    }
  end

  def get_task_and_answer(id, index) do
    GenServer.call(via(id), {:get_task_and_answer, index})
  end

  def answer_task(id, index, answer) do
    GenServer.call(via(id), {:answer_task, index, answer})
  end

  def wrap_up(id) do
    GenServer.call(via(id), :wrap_up)
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
