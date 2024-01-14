defmodule TestiroomWeb.TestLive.Components.TestForm do
  @moduledoc false
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <%= if assigns[:title] do %>
        <.header>
          <%= @title %>
        </.header>
      <% end %>
      <.simple_form for={@form} id="test-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <%= if @action == :edit do %>
          <.input field={@form[:description]} type="textarea" label={gettext("Description")} />

          <h2 class="block text-lg font-semibold leading-6 text-zinc-800"><%= gettext("Synchronization") %></h2>

          <.input field={@form[:timezone]} type="hidden" id="timezone" phx-hook="TimeZoneGetter" phx-update="ignore" />
          <.input
            field={@form[:starts_at_local]}
            type="datetime-local"
            label={gettext("Starts at")}
            id="starts-at"
            phx-hook="DateTimeWithTZSetter"
            data-datetime={@form.data.starts_at}
            phx-update="ignore"
          />
          <.input
            field={@form[:ends_at_local]}
            type="datetime-local"
            label={gettext("Ends at")}
            id="ends-at"
            phx-hook="DateTimeWithTZSetter"
            data-datetime={@form.data.ends_at}
            phx-update="ignore"
          />
          <.input field={@form[:duration_in_minutes]} type="number" label={gettext("Duration in minutes")} min="1" />

          <fieldset phx-feedback-for={@form[:grades].name}>
            <legend class="block text-lg font-semibold leading-6 text-zinc-800">
              <%= gettext("Assessment Criteria") %>
            </legend>
            <div class="mt-8">
              <.inputs_for :let={grade} field={@form[:grades]}>
                <div>
                  <fieldset class="grid-cols-[100px_1fr] mt-4 inline-grid gap-2 sm:mt-2 sm:grid-flow-col sm:grid-cols-none">
                    <input type="hidden" name="test[grades_order][]" value={grade.index} />

                    <span class="py-2">
                      <%= gettext("Grade") %>
                    </span>
                    <.input field={grade[:grade]} type="text" subtype="inline" size="17" />
                    <span class="py-2">
                      <%= gettext("from") %>
                    </span>
                    <div class="flex">
                      <.input field={grade[:from]} type="number" subtype="inline" size="17" min="0" max="100" />
                      <span class="p-2">
                        %
                      </span>
                    </div>
                    <div class="col-span-2 pl-0 sm:col-span-1 sm:pl-2">
                      <.button tag={:label} name="test[grades_delete][]" value={grade.index}>
                        <span class="hidden sm:inline">
                          <.icon name="hero-x-mark-mini" />
                        </span>

                        <span class="inline sm:hidden">
                          <%= gettext("Delete grade") %>
                        </span>
                      </.button>
                    </div>
                  </fieldset>
                </div>
              </.inputs_for>
            </div>
            <.button tag={:label} name="test[grades_order][]" class="mt-3">
              <%= gettext("Add grade") %>
            </.button>
            <.error :for={msg <- Enum.map(@form[:grades].errors, &translate_error/1)}>
              <%= msg %>
            </.error>
          </fieldset>
          <input type="hidden" name="test[grades_delete][]" />

          <h2 class="block text-lg font-semibold leading-6 text-zinc-800"><%= gettext("Student report settings") %></h2>
          <.input field={@form[:show_correctness_for_student]} type="checkbox" label={gettext("Show correctness for student")} />
          <.input field={@form[:show_score_for_student]} type="checkbox" label={gettext("Show score for student")} />
          <.input field={@form[:show_grade_for_student]} type="checkbox" label={gettext("Show grade for student")} />
          <.input field={@form[:show_answer_for_student]} type="checkbox" label={gettext("Show answer for student")} />
        <% end %>
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save Test") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @zero_day ~N[0000-01-01 00:00:00]

  @impl Phoenix.LiveComponent
  def update(%{test: test} = assigns, socket) do
    changeset =
      test
      |> Map.put(:duration_in_minutes, test.duration_in_seconds && div(test.duration_in_seconds, 60))
      |> Map.put(:starts_at_local, @zero_day)
      |> Map.put(:ends_at_local, @zero_day)
      |> Exams.change_test()

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
    save_task(socket, socket.assigns.action, test_params)
  end

  defp save_task(socket, :edit, test_params) do
    case Exams.update_test(socket.assigns.test, test_params) do
      {:ok, test} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Test updated successfully"))
         |> push_patch(to: ~p"/tests/#{test}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_task(socket, :new, test_params) do
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
