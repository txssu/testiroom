defmodule Testiroom.Proctoring.AttemptsTracker do
  @moduledoc false
  @behaviour Testiroom.Proctoring.Tracker

  alias Testiroom.Proctoring.Event

  @field :attempts

  @impl Testiroom.Proctoring.Tracker
  def init([]) do
    {:ok, [], [{@field, %{}}]}
  end

  @impl Testiroom.Proctoring.Tracker
  def call(data, %Event.Started{attempt: attempt}, []) do
    Map.update(data, @field, 1, &Map.put(&1, attempt.id, attempt))
  end
end
