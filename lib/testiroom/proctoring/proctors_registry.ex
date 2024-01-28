defmodule Testiroom.Proctoring.ProctorsRegistry do
  @moduledoc false
  alias Testiroom.Repo

  @spec register(String.t()) :: {:ok, pid()} | {:error, term()}
  def register(test_id) do
    Registry.register(__MODULE__, test_id, [])
  end

  @spec notify(term()) :: :ok
  def notify(event) do
    db_event = Repo.insert!(event)

    Registry.dispatch(__MODULE__, db_event.test_id, fn entries ->
      for {pid, _value} <- entries, do: send(pid, {:proctoring, db_event})
    end)
  end
end
