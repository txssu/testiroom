defmodule Testiroom.Proctoring.CheatingTracker do
  @moduledoc false
  alias Testiroom.Proctoring.Event

  def init([]) do
    {:ok, [], [{:maybe_cheating, %{}}, {:maybe_cheated_counter, %{}}]}
  end

  def call(data, event, []) do
    data
    |> maybe_update_counter(event)
    |> change_cheating_state(event)
  end

  defp maybe_update_counter(data, %Event.MaybeCheated{user: user, process: :started}) do
    Map.update!(data, :maybe_cheated_counter, fn users ->
      Map.update(users, user.id, 1, &(&1 + 1))
    end)
  end

  defp maybe_update_counter(data, _event), do: data

  defp change_cheating_state(data, %Event.MaybeCheated{user: user, process: :started}) do
    Map.update!(data, :maybe_cheating, fn users ->
      Map.put(users, user.id, true)
    end)
  end

  defp change_cheating_state(data, %Event.MaybeCheated{user: user, process: :ended}) do
    Map.update!(data, :maybe_cheating, fn users ->
      Map.put(users, user.id, false)
    end)
  end
end
