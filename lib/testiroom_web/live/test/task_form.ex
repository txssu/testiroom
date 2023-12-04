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
      "mb-3 border-y-2 p-3 flex flex-col gap-6",
      if @deleted do
        "hidden"
      else
        ""
      end
    ]}>
      <input type="hidden" name="test[tasks_order][]" value={@form.index} />
      <.input
        field={@form[:type]}
        type="select"
        options={Task.get_type_options()}
        label="Тип вопроса"
        prompt="Выбере тип вопроса"
      />

      <.input field={@form[:question]} type="text" label="Текст вопроса" />

      <%!-- lib/my_app_web/live/upload_live.html.heex --%>
      <.live_file_input upload={@upload} />
      <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
      <section phx-drop-target={@upload.ref}>
        <%!-- render each avatar entry --%>
        <%= for entry <- @upload.entries do %>
          <article class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} />
              <figcaption><%= entry.client_name %></figcaption>
            </figure>

            <%!-- entry.progress will update automatically for in-flight entries --%>
            <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

            <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              phx-value-name={@form.name}
              aria-label="cancel"
            >
              &times;
            </button>

            <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
            <%= for err <- upload_errors(@upload, entry) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>
          </article>
        <% end %>

        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <%= for err <- upload_errors(@upload) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>
      </section>

      <.input_by_type
        myself={@myself}
        form={@form}
        type={Ecto.Changeset.get_field(@form.source, :type)}
      />
      <div>
        <label class="btn btn-secondary btn-slim">
          <input type="checkbox" name="test[tasks_delete][]" class="hidden" value={@form.index} />
          Удалить вопрос
        </label>
      </div>
    </div>
    """
  end

  def input_by_type(%{type: nil} = assigns) do
    ~H"""

    """
  end

  def input_by_type(%{type: type} = assigns) when type in ~w[radio checkbox text]a do
    ~H"""
    <fieldset phx-feedback-for={@form.name} class="flex flex-col gap-3">
      <legend class="text-lg">Варианты ответа</legend>
      <.inputs_for :let={option} field={@form[:options]}>
        <div class="flex flex-col gap-4">
          <input
            type="hidden"
            name={"test[tasks][#{@form.index}][options_order][]"}
            value={option.index}
          />
          <div class="flex items-center gap-6">
            <div>
              <.input field={option[:text]} class="!mt-0" />
            </div>
            <%= if assigns.type == :text do %>
              <.input type="hidden" field={option[:is_correct]} value="true" />
            <% else %>
              <div>
                <.input type="checkbox" field={option[:is_correct]} label="Верный ответ" />
              </div>
            <% end %>
          </div>
          <div>
            <label class="btn btn-secondary btn-slim">
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
      <div>
        <label class="btn btn-primary mt-4 btn-slim">
          <input type="checkbox" name={"test[tasks][#{@form.index}][options_order][]"} class="hidden" />
          Добавить вариант ответа
        </label>
      </div>
    </fieldset>
    """
  end

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
