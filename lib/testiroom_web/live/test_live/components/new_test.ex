defmodule TestiroomWeb.TestLive.Components.NewTest do
  @moduledoc false
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={@form} id="test-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Test</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{test: test} = assigns, socket) do
    changeset = Exams.change_test(test)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      socket.assigns.test
      |> Exams.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"test" => test_params}, socket) do
    user = socket.assigns.current_user

    case Exams.create_test(test_params, user) do
      {:ok, test} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Test created successfully"))
         |> push_navigate(to: ~p"/tests/#{test}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
