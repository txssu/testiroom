defmodule Testiroom.Exams.Helper do
  alias Ecto.Changeset

  def cast_delete_action(changeset) do
    if Changeset.get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
