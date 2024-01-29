defmodule TestiroomWeb.UserConfirmationInstructionsLive do
  @moduledoc false
  use TestiroomWeb, :live_view

  alias Testiroom.Accounts

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext("No confirmation instructions received?") %>
        <:subtitle><%= gettext("We'll send a new confirmation link to your inbox") %></:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder={gettext("Email")} required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            <%= gettext("Resend confirmation instructions") %>
          </.button>
        </:actions>
      </.simple_form>

      <p class="mt-4 text-center">
        <.link href={~p"/users/register"}><%= gettext("Register") %></.link>
        | <.link href={~p"/users/log_in"}><%= gettext("Log in") %></.link>
      </p>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  @impl Phoenix.LiveView
  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      gettext(
        "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."
      )

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
