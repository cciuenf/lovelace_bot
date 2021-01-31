defmodule Lovelace.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    bot_name = Application.get_env(:app, :bot_name)

    unless String.valid?(bot_name) do
      IO.warn("""
      Env not found Application.get_env(:app, :bot_name)
      This will give issues when generating commands
      """)
    end

    if bot_name == "" do
      IO.warn("An empty bot_name env will make '/anycommand@' valid")
    end

    children = [
      {Lovelace.Poller, []},
      {Lovelace.Matcher, []}
    ]

    opts = [strategy: :one_for_one, name: Lovelace.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
