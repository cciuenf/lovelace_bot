import Config

app_name = :lovelace

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

# server config
app_host = get_env_var.("HOST", "localhost")
app_port = get_env_var.("PORT", "4000") |> String.to_integer()

# general config
config :lovelace, bot_name: "lovelace"

if config_env() == :prod do
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

  config :lovelace, Lovelace.Endpoint,
    url: [host: app_host, port: app_port],
    server: true,
    http: [
      port: app_port,
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base
end