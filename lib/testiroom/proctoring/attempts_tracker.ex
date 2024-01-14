defmodule Testiroom.Proctoring.AttemptsTracker do
  @moduledoc false
  alias Testiroom.Proctoring.Event

  @field :attempts

  def init([]) do
    {:ok, [], [{@field, %{}}]}
  end

  def call(data, %Event.Started{attempt: attempt}, []) do
    Map.update(data, @field, 1, &Map.put(&1, attempt.id, attempt))
  end
end
