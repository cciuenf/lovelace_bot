import Config

app_host = System.get_env("HOST", "lovelace-szh7fuhjxa-ue.a.run.app")
app_port = System.get_env("PORT", "8443") |> String.to_integer()

config :lovelace, LovelaceWeb.Endpoint,
  url: [host: app_host, port: app_port, scheme: "https"],
  check_origin: true,
  server: true
