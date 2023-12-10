defmodule TestiroomWeb.TestLive.Components.EditTest do
  @moduledoc false
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage test records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="test-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:starts_at]} type="datetime-local" label="Starts at" />
        <.input field={@form[:ends_at]} type="datetime-local" label="Ends at" />
        <.input field={@form[:duration_in_seconds]} type="number" label="Duration in seconds" />
        <fieldset>
          <.inputs_for :let={grade} field={@form[:grades]}>
            <input type="hidden" name="test[grades_order][]" value={grade.index} />

            <.input field={grade[:grade]} type="text" label="Grade" />
            <.input field={grade[:from]} type="number" label="From" />

            <label>
              <input type="checkbox" name="test[grades_delete][]" value={grade.index} class="hidden" /> Delete grade
            </label>
          </.inputs_for>
          <label class="block cursor-pointer">
            <input type="checkbox" name="test[grades_order][]" class="hidden" /> add more
          </label>
        </fieldset>
        <input type="hidden" name="test[grades_delete][]" />

        <.input field={@form[:show_correctness_for_student]} type="checkbox" label="Show correctness for student" />
        <.input field={@form[:show_score_for_student]} type="checkbox" label="Show score for student" />
        <.input field={@form[:show_grade_for_student]} type="checkbox" label="Show grade for student" />
        <.input field={@form[:show_answer_for_student]} type="checkbox" label="Show answer for student" />
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
    case Exams.update_test(socket.assigns.test, test_params) do
      {:ok, test} ->
        {:noreply,
         socket
         |> put_flash(:info, "Test updated successfully")
         |> push_patch(to: ~p"/tests/#{test}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
