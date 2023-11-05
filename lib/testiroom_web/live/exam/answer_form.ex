defmodule TestiroomWeb.AnswerForm do
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  def render(%{answer: %{task: %{type: :shortanswer}}} = assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        phx-change="save-answer"
        phx-submit="ignore"
        phx-target={@myself}
        class="mb-5"
        autocomplete="off"
      >
        <.input type="text" field={@form[:text]} placeholder="Введите свой ответ" />
      </.simple_form>
    </div>
    """
  end

  def render(%{answer: %{task: %{type: type}}} = assigns) when type in ~w[multiple single]a do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        phx-change="save-answer"
        phx-submit="print-save-message"
        phx-target={@myself}
        class="mb-5"
        autocomplete="off"
      >
        <fieldset>
          <div class="flex gap-y-2.5 flex-col">
            <span class="text-sm leading-5 text-center text-inkgray">
              <%= if assigns.answer.task.type == :multiple do %>
                один или несколько ответов
              <% else %>
                один ответ
              <% end %>
            </span>
            <div :for={{option, index} <- Stream.with_index(@answer.task.options)}>
              <input
                class="peer invisible absolute h-0 w-0"
                type={task_type_to_input_type(@answer.task.type)}
                id={"option-" <> option.id}
                value={option.id}
                name={@form.name <> "[selected_options][#{task_type_to_index(@answer.task.type, index)}][task_option_id]"}
                checked={option.id in Enum.map(@answer.selected_options, & &1.task_option_id)}
              />
              <label
                class="flex py-4 px-6 rounded-lg select-none outline outline-1 outline-inkgray text-inkdark
                       peer-checked:outline-2 peer-checked:outline-primary peer-checked:bg-inklightgray"
                for={"option-" <>option.id}
              >
                <%= option.text %>
              </label>
            </div>
          </div>
        </fieldset>
      </.simple_form>
    </div>
    """
  end

  def task_type_to_input_type(:single), do: "radio"
  def task_type_to_input_type(:multiple), do: "checkbox"

  def task_type_to_index(:single, _index), do: 1
  def task_type_to_index(:multiple, index), do: index

  def update(%{answer: answer}, socket) do
    changeset = Exams.edit_student_answer(answer, %{})

    socket =
      socket
      |> assign(answer: answer)
      |> assign_changeset(changeset)

    {:ok, socket}
  end

  def handle_event("save-answer", params, socket) do
    answer_params =
      params
      |> Map.get("student_answer", %{})
      |> Map.update(
        "selected_options",
        %{},
        &Enum.into(&1, %{}, fn {index, value} -> {String.to_integer(index), value} end)
      )

    changeset =
      socket.assigns.answer
      |> Map.put(:selected_options, [])
      |> Exams.edit_student_answer(answer_params)
      |> Map.put(:action, :validate)

    send(self(), {__MODULE__, Ecto.Changeset.apply_changes(changeset)})

    {:noreply, socket}
  end

  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end

  defp assign_changeset(socket, changeset) do
    assign(socket, changeset: changeset, form: to_form(changeset))
  end
end
