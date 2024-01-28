defmodule Testiroom.Proctoring.CurrentTaskTracker do
  @moduledoc false
  @behaviour Testiroom.Proctoring.Tracker

  alias Testiroom.Proctoring.Event

  @field :current_task

  @impl Testiroom.Proctoring.Tracker
  def init([]) do
    {:ok, [], [{@field, %{}}]}
  end

  @impl Testiroom.Proctoring.Tracker
  def call(data, %Event.OpenedTask{attempt: attempt, task: task}, []) do
    Map.update(data, @field, 1, &Map.put(&1, attempt.id, task))
  end

  def call(data, %Event.Ended{attempt: attempt}, []) do
    Map.update(data, @field, 1, &Map.put(&1, attempt.id, nil))
  end
end
