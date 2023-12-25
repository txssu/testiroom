defmodule Testiroom.Proctoring do
  @moduledoc false
  def register_examinee(attempt_id) do
    Registry.register(__MODULE__, {:examinee, attempt_id}, [])
  end

  def examinee_passing_test?(attempt_id) do
    no_examinee? =
      __MODULE__
      |> Registry.lookup({:examinee, attempt_id})
      |> Enum.empty?()

    not no_examinee?
  end

  def register_proctor(test_id) do
    Registry.register(__MODULE__, {:proctor, test_id}, [])
  end

  def notify_proctor(test_id, event) do
    Registry.dispatch(__MODULE__, {:proctor, test_id}, fn entries ->
      for {pid, _value} <- entries, do: send(pid, event)
    end)
  end
end
