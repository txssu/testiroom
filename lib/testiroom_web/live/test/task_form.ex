defmodule TestiroomWeb.TaskForm do
  use TestiroomWeb, :live_component

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
      <.input field={@form[:question]} type="text" label="Текст вопроса" />
      <.input
        field={@form[:type]}
        type="select"
        options={Task.get_type_options()}
        label="Тип вопроса"
        prompt="Выбере тип вопроса"
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

  def input_by_type(%{type: nil} = assigns) do
    ~H"""

    """
  end

  def input_by_type(%{type: type} = assigns) when type in ~w[radio checkbox text]a do
    ~H"""
    <fieldset phx-feedback-for={@form.name}>
      <legend>Варианты ответа</legend>
      <.inputs_for :let={option} field={@form[:options]}>
        <div class="flex gap-4 items-end">
          <div class="row">
            <.input field={option[:text]} />
          </div>
          <%= if assigns.type == :text do %>
            <.input type="hidden" field={option[:is_correct]} value="true" />
          <% else %>
            <div class="row">
              <.input type="checkbox" field={option[:is_correct]} label="Верный?" />
            </div>
          <% end %>
          <div class="row">
            <.button
              class="btn-primary"
              type="button"
              phx-target={@myself}
              phx-click="delete-option"
              phx-value-index={option.index}
            >
              Удалить
            </.button>
          </div>
        </div>
      </.inputs_for>
      <.input_error field={@form[:options]} />
      <.button
        class="btn-primary"
        type="submit"
        name="add-option"
        value={@form.index}
        phx-target={@myself}
      >
        Добавить вариант ответа
      </.button>
    </fieldset>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, form: assigns.form)}
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

  def handle_event("delete-option", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset, index: changeset_index} ->
        existing = Ecto.Changeset.get_field(changeset, :options)
        {to_delete, rest} = List.pop_at(existing, index)

        options =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset = Ecto.Changeset.put_change(changeset, :options, options)

        send_change(changeset, changeset_index)

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def send_change(changeset, index) do
    send(self(), {__MODULE__, changeset, index})
  end
end
