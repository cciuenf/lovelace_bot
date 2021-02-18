import Config

app_host = System.get_env("HOST", "0.0.0.0")
app_port = System.get_env("PORT", "8443") |> String.to_integer()

config :lovelae, LovelaceWeb.Endpoint,
  url: [host: app_host, port: app_port, scheme: "https"],
  check_origin: true,
  server: true
