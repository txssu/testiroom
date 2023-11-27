defmodule TestiroomWeb.Live.Dashboard.Components.Menu do
  use TestiroomWeb, :html

  attr :test_id, :string
  attr :task_id, :string

  def menu(assigns) do
    ~H"""
    <.header>
      <:subtitle>Test editor</:subtitle>
      <:actions>
      <.link navigate={~p"/tests/#{@test_id}"}><%= gettext("Editor") %></.link>
      <.link navigate={~p"/tests/#{@test_id}/tasks/o/0"}><%= gettext("Tasks") %></.link>
      <.link :if={assigns[:task_id]} navigate={~p"/tests/#{@test_id}/tasks/#{@task_id}"}><%= gettext("Selected task") %></.link>
      </:actions>
    </.header>
    """
  end
end
