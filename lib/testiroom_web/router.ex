defmodule TestiroomWeb.Router do
  use TestiroomWeb, :router

  import TestiroomWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TestiroomWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; img-src 'self' data: blob:; style-src 'self' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com;"
    }

    plug :fetch_current_user

    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TestiroomWeb do
    pipe_through :browser

    live_session :index_test_list,
      on_mount: [{TestiroomWeb.UserAuth, :mount_current_user}] do
      live "/", TestListLive
    end
  end

  scope "/", TestiroomWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :tests,
      on_mount: [{TestiroomWeb.UserAuth, :ensure_authenticated}] do
      live "/tests", TestLive.Index, :index
      live "/tests/new", TestLive.Index, :new

      live "/tests/:test_id", TestLive.Edit

      live "/tests/:test_id/tasks/:order", TaskLive.Index, :index
      live "/tests/:test_id/tasks/:order/new", TaskLive.Index, :new
      live "/tests/:test_id/tasks/:order/:task_id/", TaskLive.Index, :edit
    end

    live_session :exam,
      on_mount: [{TestiroomWeb.UserAuth, :ensure_authenticated}],
      layout: {TestiroomWeb.Layouts, :exam} do
      live "/tests/:test_id/exam", ExamLive.Start

      live "/exams/:attempt_id/result", ExamLive.Result, :index
      live "/exams/:attempt_id/result/:order", ExamLive.Result, :show
      live "/exams/:attempt_id/:order", ExamLive.Testing
    end

    live_session :proctor,
      on_mount: [{TestiroomWeb.UserAuth, :ensure_authenticated}] do
      live "/tests/:test_id/proctor", ProctorLive.Progress, :index
      live "/tests/:test_id/proctor/:attempt_id", ProctorLive.Progress, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TestiroomWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:testiroom, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TestiroomWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TestiroomWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TestiroomWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TestiroomWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TestiroomWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TestiroomWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TestiroomWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
