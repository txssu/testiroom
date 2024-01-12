defmodule Testiroom.Proctoring do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Testiroom.Proctoring.Event
  alias Testiroom.Proctoring.Monitor
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

  def notify_started_cheating(test, user) do
    notify_proctor(%Event.MaybeCheated{test: test, user: user, process: :started})
  end

  def notify_ended_cheating(test, user) do
    notify_proctor(%Event.MaybeCheated{test: test, user: user, process: :ended})
  end

  @events [Event.Started, Event.OpenedTask, Event.ProvidedAnswer, Event.Ended, Event.MaybeCheated]
  def get_monitor(test_id) do
    @events
    |> Enum.flat_map(&get_events(test_id, &1))
    |> Enum.sort_by(& &1.inserted_at, DateTime)
    |> Enum.reduce(%Monitor{}, &Monitor.handle(&2, &1))
  end

  defp get_events(test_id, event_type) do
    preload_fields =
      case event_type do
        type when type in [Event.Started, Event.Ended, Event.MaybeCheated] -> [:user]
        Event.OpenedTask -> [:user, :task]
        Event.ProvidedAnswer -> [user: [], student_answer: [task: [:options], selected_options: []]]
      end

    query =
      from event in event_type,
        where: event.test_id == ^test_id,
        preload: ^preload_fields

    Repo.all(query)
  end
end
