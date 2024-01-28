defmodule Testiroom.Proctoring.TimeTracker do
  @moduledoc false

  @behaviour Testiroom.Proctoring.Tracker

  alias Testiroom.Proctoring.Event
  alias Testiroom.Proctoring.Event.Ended
  alias Testiroom.Proctoring.Event.OpenedTask

  @impl Testiroom.Proctoring.Tracker
  def init([]) do
    {:ok, [], [last_opened: %{}, spended_time_per_task: %{}, spended_time_per_task_by_user: %{}]}
  end

  @impl Testiroom.Proctoring.Tracker
  def call(data, event, []) do
    data
    |> update_spended_time_per_task(event)
    |> update_spended_time_per_task_by_user(event)
    |> update_last_opened_task(event)
  end

  defp update_spended_time_per_task(data, %module{attempt: attempt, inserted_at: datetime}) when module in [OpenedTask, Ended] do
    case data.last_opened[attempt.id] do
      nil ->
        data

      %{inserted_at: last_opened_at, task: updated_task} ->
        Map.update!(data, :spended_time_per_task, fn tasks_time ->
          append_time = DateTime.diff(datetime, last_opened_at, :millisecond)
          Map.update(tasks_time, updated_task.order, append_time, &(&1 + append_time))
        end)
    end
  end

  defp update_spended_time_per_task_by_user(data, %module{attempt: attempt, inserted_at: datetime}) when module in [OpenedTask, Ended] do
    case data.last_opened[attempt.id] do
      nil ->
        data

      %{inserted_at: last_opened_at, task: updated_task} ->
        Map.update!(data, :spended_time_per_task_by_user, fn users ->
          append_time = DateTime.diff(datetime, last_opened_at, :millisecond)

          update_user_time(users, attempt, updated_task, append_time)
        end)
    end
  end

  defp update_user_time(users, attempt, updated_task, append_time) do
    Map.update(users, attempt.id, %{updated_task.order => append_time}, fn user_time_per_task ->
      Map.update(user_time_per_task, updated_task.order, append_time, &(&1 + append_time))
    end)
  end

  defp update_last_opened_task(data, %Event.OpenedTask{attempt: attempt} = event) do
    put_in(data.last_opened[attempt.id], event)
  end

  defp update_last_opened_task(data, %Event.Ended{attempt: attempt}) do
    put_in(data.last_opened[attempt.id], nil)
  end
end
