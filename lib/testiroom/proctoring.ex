defmodule Testiroom.Proctoring do
  @moduledoc false
  alias Testiroom.Proctoring.Event
  alias Testiroom.Repo

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

  def notify_proctor(event) do
    db_event = Repo.insert!(event)

    Registry.dispatch(__MODULE__, {:proctor, db_event.test_id}, fn entries ->
      for {pid, _value} <- entries, do: send(pid, {:proctoring, db_event})
    end)
  end

  def notify_started(test, user, _student_answers) do
    notify_proctor(%Event.Started{test: test, user: user})
  end

  def notify_wrap_up(test, user) do
    notify_proctor(%Event.Ended{test: test, user: user})
  end

  def notify_open_task(test, user, task) do
    notify_proctor(%Event.OpenedTask{test: test, user: user, task: task})
  end

  def notify_answer(test, user, answer) do
    notify_proctor(%Event.ProvidedAnswer{test: test, user: user, student_answer: answer})
  end
end
