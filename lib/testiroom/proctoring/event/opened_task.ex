defmodule Testiroom.Proctoring.Event.OpenedTask do
  @moduledoc false
  @enforce_keys [:user, :task, :at]
  defstruct [:user, :task, :at]
end
