defmodule TestiroomWeb.TaskForm do
  use TestiroomWeb, :live_component

  alias Testiroom.Exams
  alias Testiroom.Exams.Task

  def render(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.form, :delete) == true
      )

    ~H"""
    <div class={[
      "mb-3 border-y-2 p-3",
      if @deleted do
        "hidden"
      else
        ""
      end
    ]}>
      <input
        type="hidden"
        name={Phoenix.HTML.Form.input_name(@form, :delete)}
        value={to_string(Phoenix.HTML.Form.input_value(@form, :delete))}
      />
      <.input field={@form[:order]} value={@form.index} type="hidden" />
      <.input field={@form[:question]} type="text" label="Текст вопроса" />
      <.input
        field={@form[:type]}
        type="select"
        options={Task.get_type_options()}
        label="Тип вопроса"
      />
      <.input_by_type
        myself={@myself}
        form={@form}
        type={Ecto.Changeset.get_field(@form.source, :type)}
      />
      <.button class="btn-primary" type="button" phx-click="delete-task" phx-target={@myself}>
        Удалить
      </.button>
    </div>
    """
  end

  def input_by_type(%{type: :shortanswer} = assigns) do
    ~H"""
    <.input field={@form[:answer]} type="text" label="Ответ на вопрос" />
    """
  end

  def input_by_type(%{type: type} = assigns) when type in ~w[single multiple]a do
    ~H"""
    <fieldset>
      <legend>Варианты ответа</legend>
      <.inputs_for :let={option} field={@form[:options]}>
        <div class="flex gap-4 items-end">
          <div class="row">
            <.input field={option[:text]} />
          </div>
          <div class="row">
            <.input type="checkbox" field={option[:is_correct]} label="Верный?" />
          </div>
        </div>
      </.inputs_for>
      <.input_error field={@form[:options]} />
      <.button type="button" phx-click="add-option" phx-target={@myself} phx-value-index={@form.index}>
        Добавить вариант ответа
      </.button>
    </fieldset>
    """
  end

  def handle_event("add-option", _params, socket) do
    socket =
      update(socket, :form, fn %{source: changeset, index: index} ->
        existing = Ecto.Changeset.get_change(changeset, :options) || []

        changeset =
          Ecto.Changeset.put_change(changeset, :options, existing ++ [Exams.new_task_option()])

        send_change(changeset, index)

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("delete-task", _params, socket) do
    socket =
      update(socket, :form, fn %{source: changeset, index: index} ->
        changeset = Ecto.Changeset.change(changeset, delete: true)

        send_change(changeset, index)

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def send_change(changeset, index) do
    send(self(), {__MODULE__, changeset, index})
  end

  def update(assigns, socket) do
    {:ok, assign(socket, form: assigns.form)}
  end
end
