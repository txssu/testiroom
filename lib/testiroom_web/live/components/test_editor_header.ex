defmodule TestiroomWeb.Live.Components.TestEditorHeader do
  @moduledoc false
  use TestiroomWeb, :html

  attr :test_id, :string
  attr :active, :atom, values: ~w[editor tasks]a

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def test_editor_header(assigns) do
    ~H"""
    <.header class="border-b-2">
      <%= render_slot(@inner_block) %>
      <:subtitle><%= render_slot(@subtitle) %></:subtitle>
      <:actions>
        <div class="flex h-full flex-nowrap items-end space-x-4">
          <.button tag={:link} kind={:base} patch={~p"/tests/#{@test_id}/"} class={active_class(@active == :editor)}>
            <%= gettext("Editor") %>
          </.button>
          <.button tag={:link} kind={:base} patch={~p"/tests/#{@test_id}/tasks/0"} class={active_class(@active == :tasks)}>
            <%= gettext("Tasks") %>
          </.button>
        </div>
      </:actions>
    </.header>
    """
  end

  defp active_class(true) do
    "rounded-t-lg bg-primary text-white"
  end

  defp active_class(false) do
    "rounded-t-lg hover:bg-ink-light-gray"
  end
end
