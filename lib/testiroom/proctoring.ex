defmodule Testiroom.Proctoring do
  @moduledoc false

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
      for {pid, _value} <- entries, do: send(pid, event)
    end)
  end

  def notify_started(test, user, student_answers) do
    notify_proctor(test.id, {:started, user, student_answers})
  end

  def notify_answer(test_id, user_id, answer) do
    notify_proctor(test_id, {:answer, user_id, answer})
  end

  def notify_wrap_up(test_id, user_id) do
    notify_proctor(test_id, {:wrap_up, user_id})
  end

  def notify_open_task(test_id, user_id, order) do
    notify_proctor(test_id, {:open_task, user_id, order})
  end
end
