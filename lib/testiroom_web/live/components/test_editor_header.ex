defmodule TestiroomWeb.Live.Components.TestEditorHeader do
  @moduledoc false
  use TestiroomWeb, :html

  attr :test_id, :string

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def test_editor_header(assigns) do
    ~H"""
    <.header>
      <%= render_slot(@inner_block) %>
      <:subtitle><%= render_slot(@subtitle) %></:subtitle>
      <:actions>
        <.link patch={~p"/tests/#{@test_id}/"}>
          <%= gettext("Editor") %>
        </.link>
        <.link patch={~p"/tests/#{@test_id}/tasks/0"}>
          <%= gettext("Tasks") %>
        </.link>
      </:actions>
    </.header>
    """
  end
end
