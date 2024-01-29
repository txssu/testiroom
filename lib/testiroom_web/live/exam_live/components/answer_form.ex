# credo:disable-for-this-file Credo.Check.Readability.Specs
defmodule TestiroomWeb.ExamLive.Components.AnswerForm do
  @moduledoc false
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="validate" phx-target={@myself}>
        <%= case @answer.task.type do %>
          <% :text -> %>
            <.input
              type="text"
              subtype="wide"
              field={@form[:text_input]}
              placeholder={prompt_message(:text)}
              autocomplete="off"
              phx-debounce="blur"
            />
          <% type when type in [:single, :multiple] -> %>
            <fieldset>
              <div phx-feedback-for={@form[:selected_options].name}>
                <legend class="text-ink-gray w-full text-center text-sm leading-5">
                  <%= prompt_message(type) %>
                </legend>
                <.option
                  :for={{option, index} <- Stream.with_index(@answer.task.options)}
                  field={@form[:selected_options]}
                  type={@answer.task.type}
                  option={option}
                  index={index}
                />
                <.error :for={msg <- Enum.map(@form[:selected_options].errors, &translate_error/1)}>
                  <%= msg %>
                </.error>
              </div>
            </fieldset>
        <% end %>
      </.form>
    </div>
    """
  end

  defp option(%{type: type, index: index, field: field, option: option} = assigns) do
    name_index =
      case type do
        :single -> "[0][id]"
        :multiple -> "[#{index}][id]"
      end

    input_type =
      case type do
        :single -> "radio"
        :multiple -> "checkbox"
      end

    name = field.name <> name_index
    checked? = option.id in Enum.map(field.form.data.selected_options, & &1.id)
    id = "#{field.id}-#{option.id}"
    assigns = assign(assigns, name: name, checked?: checked?, type: type, id: id, input_type: input_type)

    ~H"""
    <div phx-feedback-for={@name} class="mt-2.5">
      <input
        class="peer invisible absolute h-0 w-0"
        id={@id}
        type={@input_type}
        name={@name}
        value={@option.id}
        checked={@checked?}
      />
      <label
        class={[
          "flex select-none rounded-lg px-6 py-4 outline outline-1",
          "outline-ink-gray text-ink-dark",
          "peer-checked:outline-primary peer-checked:bg-ink-light-gray peer-checked:outline-2"
        ]}
        for={@id}
      >
        <%= @option.text %>
      </label>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{answer: answer} = assigns, socket) do
    changeset = Exams.change_student_answer(answer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", params, socket) do
    student_answer_params = params["student_answer"] || %{}
    selected_options_params = params["student_answer"]["selected_options"] || []

    answer = socket.assigns.answer
    options = answer.task.options

    selected_options = Enum.map(selected_options_params, &fetch_options(&1, options))

    updated_socket =
      case Exams.update_student_answer(answer, selected_options, student_answer_params) do
        {:ok, answer} ->
          notify_parent(answer)
          socket

        {:error, :attempt_is_ended} ->
          notify_parent(:attempt_is_ended)
          socket

        {:error, changeset} ->
          assign_form(socket, changeset)
      end

    {:noreply, updated_socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp fetch_options({_index, param}, options) do
    option_id = param["id"]
    Enum.find(options, &(option_id == &1.id))
  end

  defp prompt_message(:single), do: gettext("one answer")
  defp prompt_message(:multiple), do: gettext("one or more answers")
  defp prompt_message(:text), do: gettext("Enter your answer")
end
