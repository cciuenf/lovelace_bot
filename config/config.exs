use Mix.Config

config :tesla, adapter: Tesla.Adapter.Hackney

config :app, bot_name: "lovelace"

import_config "#{Mix.env()}.exs"
