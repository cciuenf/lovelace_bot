defmodule Lovelace.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    bot_name = Application.get_env(:lovelace, :bot_name)
    port = Application.get_env(:lovelace, :port)

    unless String.valid?(bot_name) do
      IO.warn("""
      Env not found Application.get_env(:lovelace, :bot_name)
      This will give issues when generating commands
      """)
    end

    if bot_name == "" do
      IO.warn("An empty bot_name env will make '/anycommand@' valid")
    end

    children = [
      {Lovelace.Poller, []},
      {Lovelace.Matcher, []},
      {Plug.Cowboy, scheme: :http, plug: Lovelace.Server, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: Lovelace.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
