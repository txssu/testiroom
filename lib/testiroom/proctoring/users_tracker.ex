defmodule Testiroom.Proctoring.UsersTracker do
  @moduledoc false
  alias Testiroom.Proctoring.Event

  @field :users

  def init([]) do
    {:ok, [], [{@field, %{}}]}
  end

  def call(data, %Event.Started{user: user}, []) do
    Map.update(data, @field, 1, &Map.put(&1, user.id, user))
  end
end
