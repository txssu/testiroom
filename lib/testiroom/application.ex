defmodule Testiroom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, _} = EctoBootMigration.migrate(:testiroom)

    children = [
      TestiroomWeb.Telemetry,
      Testiroom.Repo,
      {DNSCluster, query: Application.get_env(:testiroom, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Testiroom.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Testiroom.Finch},
      # Start a worker by calling: Testiroom.Worker.start_link(arg)
      # {Testiroom.Worker, arg},
      # Start to serve requests, typically the last entry
      TestiroomWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Testiroom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TestiroomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
