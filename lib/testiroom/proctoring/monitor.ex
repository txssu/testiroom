defmodule Testiroom.Proctoring.Monitor do
  @moduledoc false
  use Testiroom.Proctoring.Dispatcher

  alias Testiroom.Proctoring.AnswersTracker
  alias Testiroom.Proctoring.Counter
  alias Testiroom.Proctoring.CurrentTaskTracker
  alias Testiroom.Proctoring.Event
  alias Testiroom.Proctoring.TimeTracker
  alias Testiroom.Proctoring.UsersTracker

  defhandler Event.Started, Counter, :started_counter
  defhandler Event.Ended, Counter, :ended_counter

  defhandler Event.Started, UsersTracker

  defhandler Event.OpenedTask, CurrentTaskTracker
  defhandler Event.Ended, CurrentTaskTracker

  defhandler Event.OpenedTask, TimeTracker
  defhandler Event.Ended, TimeTracker

  defhandler Event.ProvidedAnswer, AnswersTracker
end
