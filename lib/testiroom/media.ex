defmodule Testiroom.Media do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "media" do
    field :path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, [:path])
    |> validate_required([:path])
  end
end
