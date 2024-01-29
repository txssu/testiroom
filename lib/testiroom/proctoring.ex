defmodule Testiroom.Proctoring do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Testiroom.Exams.Attempt
  alias Testiroom.Exams.StudentAnswer
  alias Testiroom.Exams.Test
  alias Testiroom.Proctoring.Event
  alias Testiroom.Proctoring.ExamineesRegistry
  alias Testiroom.Proctoring.Monitor
  alias Testiroom.Proctoring.ProctorsRegistry
  alias Testiroom.Repo

  @spec register_proctor(String.t()) :: {:ok, pid()} | {:error, {:already_registered, pid()}}
  def register_proctor(test_id) do
    ProctorsRegistry.register(test_id)
  end

  @spec register_examinee(String.t()) :: {:ok, pid()} | {:error, {:already_registered, pid()}}
  def register_examinee(attempt_id) do
    ExamineesRegistry.register(attempt_id)
  end

  @spec notify_started(Test.t(), Attempt.t()) :: :ok
  def notify_started(test, attempt) do
    ProctorsRegistry.notify(%Event.Started{test: test, attempt: attempt})
  end

  @spec notify_wrap_up(Test.t(), Attempt.t()) :: :ok
  def notify_wrap_up(test, attempt) do
    ProctorsRegistry.notify(%Event.Ended{test: test, attempt: attempt})
  end

  @spec notify_open_task(Test.t(), Attempt.t(), Task.t()) :: :ok
  def notify_open_task(test, attempt, task) do
    ProctorsRegistry.notify(%Event.OpenedTask{test: test, attempt: attempt, task: task})
  end

  @spec notify_answer(Test.t(), Attempt.t(), StudentAnswer.t()) :: :ok
  def notify_answer(test, attempt, answer) do
    ProctorsRegistry.notify(%Event.ProvidedAnswer{test: test, attempt: attempt, student_answer: answer})
  end

  @spec notify_started_cheating(Test.t(), Attempt.t()) :: :ok
  def notify_started_cheating(test, attempt) do
    ProctorsRegistry.notify(%Event.MaybeCheated{test: test, attempt: attempt, process: :started})
  end

  @spec notify_ended_cheating(Test.t(), Attempt.t()) :: :ok
  def notify_ended_cheating(test, attempt) do
    ProctorsRegistry.notify(%Event.MaybeCheated{test: test, attempt: attempt, process: :ended})
  end

  @events [Event.Started, Event.OpenedTask, Event.ProvidedAnswer, Event.Ended, Event.MaybeCheated]
  @spec get_monitor(String.t()) :: [term()]
  def get_monitor(test_id) do
    @events
    |> Enum.flat_map(&get_events(test_id, &1))
    |> Enum.sort_by(& &1.inserted_at, DateTime)
    |> Enum.reduce(%Monitor{}, &Monitor.handle(&2, &1))
  end

  defp get_events(test_id, event_type) do
    preload_fields =
      case event_type do
        type when type in [Event.Started, Event.Ended, Event.MaybeCheated] ->
          [attempt: [user: [], student_answers: [task: [:options], selected_options: []]]]

        Event.OpenedTask ->
          [attempt: [:user], task: []]

        Event.ProvidedAnswer ->
          [attempt: [:user], student_answer: [task: [:options], selected_options: []]]
      end

    query =
      from event in event_type,
        where: event.test_id == ^test_id,
        preload: ^preload_fields

    Repo.all(query)
  end
end
