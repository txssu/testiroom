defmodule Testiroom.Proctoring.Tracker do
  @moduledoc false
  alias Testiroom.Proctoring.Monitor

  @callback init(term()) :: {:ok, term(), Keyword.t()}

  @callback call(Monitor.t(), term(), term()) :: Monitor.t()
end
