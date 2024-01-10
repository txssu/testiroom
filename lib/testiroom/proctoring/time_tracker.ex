defmodule Testiroom.Proctoring.TimeTracker do
  @moduledoc false
  alias Testiroom.Proctoring.Event

  def init([]) do
    {:ok, [], [last_opened: %{}, spended_time_per_task: %{}]}
  end

  def call(data, event, []) do
    data
    |> update_spended_time_per_task(event)
    |> update_last_opened_task(event)
  end

  defp update_spended_time_per_task(data, %{user: user, at: datetime}) do
    case data.last_opened[user.id] do
      nil ->
        data

      %{at: last_opened_at, task: updated_task} ->
        Map.update!(data, :spended_time_per_task, fn tasks_time ->
          append_time = DateTime.diff(datetime, last_opened_at, :millisecond)
          Map.update(tasks_time, updated_task.order, append_time, &(&1 + append_time))
        end)
    end
  end

  defp update_last_opened_task(data, %Event.OpenedTask{user: user} = event) do
    put_in(data.last_opened[user.id], event)
  end

  defp update_last_opened_task(data, %Event.Ended{user: user}) do
    put_in(data.last_opened[user.id], nil)
  end
end
