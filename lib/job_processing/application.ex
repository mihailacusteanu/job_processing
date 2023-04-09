defmodule JobProcessing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      JobProcessingWeb.Telemetry,
      # Start the Ecto repository
      # JobProcessing.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: JobProcessing.PubSub},
      # Start Finch
      {Finch, name: JobProcessing.Finch},
      # Start the Endpoint (http/https)
      JobProcessingWeb.Endpoint
      # Start a worker by calling: JobProcessing.Worker.start_link(arg)
      # {JobProcessing.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobProcessing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JobProcessingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
