defmodule Testiroom.Proctoring.Counter do
  @moduledoc false
  def init(counter_name) do
    {:ok, counter_name, [{counter_name, 0}]}
  end

  def call(data, _event, counter_name) do
    Map.update(data, counter_name, 1, &(&1 + 1))
  end
end
