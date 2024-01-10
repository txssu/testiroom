defmodule Testiroom.Proctoring.Monitor do
  @moduledoc false
  use Testiroom.Proctoring.Dispatcher

  alias Testiroom.Proctoring.Counter
  alias Testiroom.Proctoring.Event
  alias Testiroom.Proctoring.UsersTracker

  handle Event.Started, Counter, :started_counter
  handle Event.Ended, Counter, :ended_counter

  handle Event.Started, UsersTracker

  # handle :open_task, CurrentTaskTracker

  # handle :open_task, TotalTimeTracker
  # handle :open_task, TaskTimeTracker
  # handle :open_task, UserTimeTracker
end
