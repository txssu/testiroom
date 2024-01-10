defmodule Testiroom.Proctoring.CurrentTaskTracker do
  @moduledoc false
  alias Testiroom.Proctoring.Event

  @field :current_task

  def init([]) do
    {:ok, [], [{@field, %{}}]}
  end

  def call(data, %Event.OpenedTask{user: user, task: task}, []) do
    Map.update(data, @field, 1, &Map.put(&1, user.id, task))
  end

  def call(data, %Event.Ended{user: user}, []) do
    Map.update(data, @field, 1, &Map.put(&1, user.id, nil))
  end
end
