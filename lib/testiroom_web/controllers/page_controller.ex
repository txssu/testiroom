defmodule TestiroomWeb.PageController do
  use TestiroomWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    redirect(conn, to: ~p"/tests")
  end
end
