import Config

get_env_var = fn var_name, default ->
  value = System.get_env(var_name)

  cond do
    default != :none ->
      default

    is_nil(value) or value == "" ->
      raise """
      Environment variable #{var_name} is missing!
      """

    true ->
      value
  end
end

# general config
config :lovelace, bot_name: "lovelace"

if config_env() == :prod do
  # server config
  app_host = get_env_var.("HOST", "0.0.0.0")
  app_port = get_env_var.("PORT", "8443") |> String.to_integer()

  # bot config
  bot_token = get_env_var.("BOT_TOKEN", :none)

  # database config
  db_url = get_env_var.("DB_URL", :none)
  pool_size = get_env_var.("POOL_SIZE", "2") |> String.to_integer()

  # server config
  secret_key_base = get_env_var.("SECRET_KEY_BASE", :none)

  config :lovelace, bot_token: bot_token

  config :lovelace, Lovelace.Repo,
    url: db_url,
    pool_size: pool_size

  config :lovelace, LovelaceWeb.Endpoint,
    server: true,
    url: [host: app_host, port: app_port],
    http: [
      port: app_port,
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base
end
