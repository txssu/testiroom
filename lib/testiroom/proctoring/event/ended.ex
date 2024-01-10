defmodule Testiroom.Proctoring.Event.Ended do
  @moduledoc false
  @keys ~w[user at]a
  @enforce_keys @keys
  defstruct @keys
end
