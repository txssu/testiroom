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

  defp maybe_update_counter(data, %Event.MaybeCheated{attempt: attempt, process: :started}) do
    Map.update!(data, :maybe_cheated_counter, fn users ->
      Map.update(users, attempt.id, 1, &(&1 + 1))
    end)
  end

  defp maybe_update_counter(data, _event), do: data

  defp change_cheating_state(data, %Event.MaybeCheated{attempt: attempt, process: :started}) do
    Map.update!(data, :maybe_cheating, fn users ->
      Map.put(users, attempt.id, true)
    end)
  end

  defp change_cheating_state(data, %Event.MaybeCheated{attempt: attempt, process: :ended}) do
    Map.update!(data, :maybe_cheating, fn users ->
      Map.put(users, attempt.id, false)
    end)
  end
end
