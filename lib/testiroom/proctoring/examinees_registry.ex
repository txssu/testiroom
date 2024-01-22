defmodule Testiroom.Proctoring.ExamineesRegistry do
  @moduledoc false
  def register(attempt_id) do
    Registry.register(__MODULE__, attempt_id, [])
  end
end
