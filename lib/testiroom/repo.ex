defmodule Testiroom.Repo do
  use Ecto.Repo,
    otp_app: :testiroom,
    adapter: Ecto.Adapters.Postgres
end
