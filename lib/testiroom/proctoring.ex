defmodule Testiroom.Proctoring do
  @moduledoc false
  def register_proctor(test_id) do
    Registry.register(__MODULE__, test_id, [])
  end

  def notify_proctor(test_id, event) do
    Registry.dispatch(__MODULE__, test_id, fn entries ->
      for {pid, _value} <- entries, do: send(pid, event)
    end)
  end
end
