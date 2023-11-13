defmodule TestiroomWeb.AnonymousToken do
  @moduledoc """
  Reads a user_details cookie and puts user_details into session
  """
  import Plug.Conn

  @identity_cookie "anonymous_identity"
  @cookie_max_age 30 * 24 * 60 * 60
  @identity_key :anonymous_identity

  def init(_) do
    %{}
  end

  def call(conn, _opts) do
    conn = fetch_cookies(conn)

    identity = conn.cookies[@identity_cookie]

    put_identity(conn, identity)
  end

  def put_identity(conn, identity)

  def put_identity(conn, nil) do
    identity = Ecto.UUID.generate()

    conn
    |> put_resp_cookie(@identity_cookie, identity, max_age: @cookie_max_age)
    |> put_identity(identity)
  end

  def put_identity(conn, identity) do
    conn
    # Makes it available in LiveView
    |> put_session(@identity_key, identity)
    # Makes it available in traditional controllers etc
    |> assign(@identity_key, identity)
  end
end
