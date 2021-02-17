defmodule Lovelace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias LovelaceIntegration.Telegram.Consumers

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Lovelace.Repo,
      # Start the Telemetry supervisor
      LovelaceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Lovelace.PubSub},
      # Start the consumer for telegram messages
      Consumers.MessageHandler,
      # Start the Endpoint (http/https)
      LovelaceWeb.Endpoint
      # Start a worker by calling: Lovelace.Worker.start_link(arg)
      # {Lovelace.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lovelace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LovelaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
