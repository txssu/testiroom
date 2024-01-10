defmodule Testiroom.Proctoring.Event.ProvidedAnswer do
  @moduledoc false
  @keys ~w[user answer]a
  @enforce_keys @keys
  defstruct @keys
end
