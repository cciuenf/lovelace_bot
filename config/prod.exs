import Config

app_host = System.get_env("HOST", "0.0.0.0")
app_port = System.get_env("PORT", "8443") |> String.to_integer()

config :lovelace, LovelaceWeb.Endpoint,
  url: [host: app_host, port: app_port],
  check_origin: true,
  server: true
