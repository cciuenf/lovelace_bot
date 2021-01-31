use Mix.Config

config :tesla, adapter: Tesla.Adapter.Hackney

config :lovelace, bot_name: "lovelace"

import_config "#{Mix.env()}.exs"
