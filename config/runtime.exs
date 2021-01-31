import Config

bot_token = System.get_env("BOT_TOKEN")
port = System.get_env("PORT", "3333") |> String.to_integer()

config :nadia, token: bot_token

config :lovelace, port: port
