defmodule Testiroom.Proctoring.ExamineesRegistry do
  @moduledoc false

  @spec register(String.t()) :: {:ok, pid()} | {:error, term()}
  def register(attempt_id) do
    Registry.register(__MODULE__, attempt_id, [])
  end
end
