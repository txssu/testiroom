defmodule TestiroomWeb.AnswerForm do
  use TestiroomWeb, :live_component

  alias Testiroom.Exams

  def render(assigns) do
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
        <.input type="text" field={@form[:text]} label={@answer.task.question} />
      </.simple_form>
    </div>
    """
  end

  def update(%{answer: answer}, socket) do
    changeset = Exams.edit_student_answer(answer, %{})

    socket =
      socket
      |> assign(answer: answer)
      |> assign_changeset(changeset)

    {:ok, socket}
  end

  def handle_event("save-answer", %{"student_answer" => answer_params}, socket) do
    changeset =
      socket.assigns.answer
      |> Exams.edit_student_answer(answer_params)
      |> Map.put(:action, :validate)

    send(self(), {__MODULE__, Ecto.Changeset.apply_changes(changeset)})

    {:noreply, assign_changeset(socket, changeset)}
  end

  def handle_event("print-save-message", _params, socket) do
    {:noreply, socket}
  end

  defp assign_changeset(socket, changeset) do
    assign(socket, changeset: changeset, form: to_form(changeset))
  end
end
