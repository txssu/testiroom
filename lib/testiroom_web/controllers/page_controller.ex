defmodule TestiroomWeb.PageController do
  use TestiroomWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: ~p"/tests")
  end
end
