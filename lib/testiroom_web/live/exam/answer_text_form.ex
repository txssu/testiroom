defmodule TestiroomWeb.AnswerTextForm do
  use TestiroomWeb, :live_component

  alias Testiroom.Exams.StudentAnswer
  alias TestiroomWeb.Gettext

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="validate" phx-target={@myself}>
        <.input
          field={@form[:text]}
          placeholder={Gettext.gettext("Type your answer")}
          autocomplete="off"
        />
      </.form>
    </div>
    """
  end

  def update(%{answer: answer} = assigns, socket) do
    changeset = StudentAnswer.text_changeset(answer, %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  def handle_event("validate", %{"student_answer" => answer_params}, socket) do
    changeset =
      socket.assigns.answer
      |> StudentAnswer.text_changeset(answer_params)
      |> Map.put(:action, :validate)

    changeset
    |> Ecto.Changeset.apply_changes()
    |> send_answer_to_parent()

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  def send_answer_to_parent(answer) do
    send(self(), {:answer_form, answer})
  end
end
