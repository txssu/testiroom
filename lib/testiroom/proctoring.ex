defmodule Testiroom.Proctoring do
  @moduledoc false
  alias Testiroom.Proctoring.Event

  def register_proctor(test_id) do
    Registry.register(__MODULE__, {:proctor, test_id}, [])
  end

  def register_examinee(attempt_id) do
    Registry.register(__MODULE__, {:examinee, attempt_id}, [])
  end

  def examinee_passing_test?(attempt_id) do
    no_examinee? =
      __MODULE__
      |> Registry.lookup({:examinee, attempt_id})
      |> Enum.empty?()

    not no_examinee?
  end

  def notify_proctor(test_id, event) do
    Registry.dispatch(__MODULE__, {:proctor, test_id}, fn entries ->
      for {pid, _value} <- entries, do: send(pid, {:proctoring, event})
    end)
  end

  def notify_started(test, user, _student_answers) do
    notify_proctor(test.id, %Event.Started{user: user})
  end

  def notify_wrap_up(test_id, user) do
    notify_proctor(test_id, %Event.Ended{user: user, at: DateTime.utc_now()})
  end

  def notify_open_task(test_id, user, task) do
    notify_proctor(test_id, %Event.OpenedTask{user: user, task: task, at: DateTime.utc_now(:millisecond)})
  end

  def notify_answer(test_id, user, answer) do
    notify_proctor(test_id, %Event.ProvidedAnswer{user: user, answer: answer})
  end
end
