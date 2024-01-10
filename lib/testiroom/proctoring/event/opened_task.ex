defmodule Testiroom.Proctoring.Event.OpenedTask do
  @moduledoc false
  @enforce_keys [:user, :task]
  defstruct user: nil, task: nil
end
