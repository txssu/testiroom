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
        <.input type="text" field={@form[:text]} label={@answer.task.question} />
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
          <legend><%= @answer.task.question %></legend>
          <label
            :for={{option, index} <- Stream.with_index(@answer.task.options)}
            class="block"
            for={"option-" <>option.id}
          >
            <input
              type={task_type_to_input_type(@answer.task.type)}
              id={"option-" <> option.id}
              value={option.id}
              name={@form.name <> "[selected_options][#{task_type_to_index(@answer.task.type, index)}][task_option_id]"}
              checked={option.id in Enum.map(@answer.selected_options, & &1.task_option_id)}
            />
            <%= option.text %>
          </label>
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

    {:noreply, assign_changeset(socket, changeset)}
  end

  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end

  defp assign_changeset(socket, changeset) do
    assign(socket, changeset: changeset, form: to_form(changeset))
  end
end
