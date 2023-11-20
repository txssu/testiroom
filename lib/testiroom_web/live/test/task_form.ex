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
      <input type="hidden" name="test[tasks_order][]" value={@form.index} />

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
      <label class="btn btn-secondary">
        <input type="checkbox" name="test[tasks_delete][]" class="hidden" value={@form.index} />
        Удалить
      </label>
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
          <input
            type="hidden"
            name={"test[tasks][#{@form.index}][options_order][]"}
            value={option.index}
          />

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
            <label class="btn btn-primary">
              <input
                type="checkbox"
                name={"test[tasks][#{@form.index}][options_delete][]"}
                class="hidden"
                value={option.index}
              /> Удалить
            </label>
          </div>
        </div>
      </.inputs_for>
      <.input_error field={@form[:options]} />
      <label class="btn btn-primary">
        <input type="checkbox" name={"test[tasks][#{@form.index}][options_order][]"} class="hidden" />
        Добавить вариант ответа
      </label>
    </fieldset>
    """
  end
end
