defmodule Testiroom.Exams.AttemptManager do
  use GenServer

  alias Testiroom.Exams.StudentAttempt
  alias :ets, as: ETS

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_attempt(user, student_attempt) do
    GenServer.call(__MODULE__, {:start_attempt, user, student_attempt})
  end

  def started?(id) do
    GenServer.call(__MODULE__, {:started?, id})
  end

  def get_tasks_count(id) do
    GenServer.call(__MODULE__, {:get_tasks_count, id})
  end

  def get_task_and_answer(id, index) do
    GenServer.call(__MODULE__, {:get_task_and_answer, id, index})
  end

  def answer_task(id, index, answer) do
    GenServer.call(__MODULE__, {:answer_task, id, index, answer})
  end

  def wrap_up(id) do
    GenServer.call(__MODULE__, {:wrap_up, id})
  end

  def init(_init_arg) do
    {:ok, ETS.new(__MODULE__, [])}
  end

  def handle_call({:started?, id}, _from, table) do
    result = ETS.lookup(table, id)
    {:reply, result != [], table}
  end

  def handle_call({:start_attempt, user, student_attempt}, _from, table) do
    id = via(user, student_attempt)
    ETS.insert(table, {id, student_attempt})
    {:reply, id, table}
  end

  def handle_call({:get_tasks_count, id}, _from, table) do
    [{_key, student_attempt}] = ETS.lookup(table, id)

    {:reply, student_attempt.count, table}
  end

  def handle_call({:get_task_and_answer, id, index}, _from, table) do
    [{_key, student_attempt}] = ETS.lookup(table, id)

    task = StudentAttempt.get_task(student_attempt, index)
    answer = StudentAttempt.get_answer(student_attempt, index)
    done_status = StudentAttempt.done_status(student_attempt)

    {:reply, {task, answer, done_status}, table}
  end

  def handle_call({:answer_task, id, index, answer}, _from, table) do
    [{_key, student_attempt}] = ETS.lookup(table, id)

    student_attempt = StudentAttempt.answer_task(student_attempt, index, answer)

    ETS.insert(table, {id, student_attempt})

    {:reply, :ok, table}
  end

  def handle_call({:wrap_up, id}, _from, table) do
    [{_key, student_attempt}] = ETS.lookup(table, id)

    ETS.delete(table, id)

    {:reply, student_attempt, table}
  end

  defp via(user, student_attempt) do
    {user.id, student_attempt.test.id}
  end
end
