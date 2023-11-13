defmodule TestiroomWeb.AnswerOptionsForm do
  use TestiroomWeb, :live_component

  alias Testiroom.Exams.StudentAnswer

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="validate" phx-target={@myself}>
        <fieldset class="flex flex-col gap-2.5">
          <.option
            :for={{option, index} <- Stream.with_index(@task.options)}
            field={@form[:selected_options]}
            type={@task.type}
            option={option}
            index={index}
          />
        </fieldset>
      </.form>
    </div>
    """
  end

  def option(%{type: type, index: index, field: field, option: option} = assigns) do
    name_index =
      case type do
        :radio -> "[0][id]"
        :checkbox -> "[#{index}][id]"
      end

    name = field.name <> name_index
    checked? = option.id in Enum.map(field.form.data.selected_options, & &1.id)
    id = "#{field.id}-#{option.id}"
    assigns = assign(assigns, name: name, checked?: checked?, type: type, id: id)

    ~H"""
    <div phx-feedback-for={@name}>
      <input
        class="peer invisible absolute h-0 w-0"
        id={@id}
        type={@type}
        name={@name}
        value={@option.id}
        checked={@checked?}
      />
      <label
        class={[
          "flex py-4 px-6 rounded-lg select-none outline outline-1",
          "outline-ink-gray text-ink-dark",
          "peer-checked:outline-2 peer-checked:outline-primary peer-checked:bg-ink-lightgray"
        ]}
        for={id}
      >
        <%= @option.text %>
      </label>
    </div>
    """
  end

  def update(%{answer: answer} = assigns, socket) do
    changeset = StudentAnswer.options_changeset(answer, %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    selected_options_params = params["student_answer"]["selected_options"] || []

    options = socket.assigns.task.options
    selected_options = Enum.map(selected_options_params, &fetch_options(&1, options))

    answer =
      socket.assigns.answer
      |> Map.put(:selected_options, selected_options)

    send_answer_to_parent(answer)
    changeset = StudentAnswer.options_changeset(answer, %{})

    {:noreply, assign_form(socket, changeset)}
  end

  def fetch_options({_index, param}, options) do
    option_id = param["id"]
    Enum.find(options, &(option_id == &1.id))
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  def send_answer_to_parent(answer) do
    send(self(), {:answer_form, answer})
  end
end
