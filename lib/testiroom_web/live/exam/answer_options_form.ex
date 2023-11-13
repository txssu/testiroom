defmodule TestiroomWeb.AnswerOptionsForm do
  use TestiroomWeb, :live_component

  alias Testiroom.Exams.StudentAnswer

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="validate" phx-target={@myself}>
        <.option
          :for={{option, index} <- Stream.with_index(@task.options)}
          field={@form[:selected_options]}
          type={@task.type}
          option={option}
          index={index}
        />
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
    assigns = assign(assigns, name: name, checked?: checked?, type: type)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input
          id={@field.id}
          type={@type}
          name={@name}
          value={@option.id}
          checked={@checked?}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
        />
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

  def handle_event("validate", %{"student_answer" => %{"selected_options" => params}}, socket) do
    options = socket.assigns.task.options
    selected_options = Enum.map(params, &fetch_options(&1, options))

    answer =
      socket.assigns.answer
      |> Map.put(:selected_options, selected_options)

    send_answer_to_parent(answer)
    changeset = StudentAnswer.options_changeset(answer, %{})

    {:noreply, assign_form(socket, changeset)}
  end

  def fetch_options({_index, param} = x, options) do
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
