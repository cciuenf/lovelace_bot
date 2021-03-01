import Config

config :lovelace,
  ecto_repos: [Lovelace.Repo],
  generators: [binary_id: false]

# Configures the endpoint
config :lovelace, LovelaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+41x5h8Xbn3ilu0YZ5UShcHI2/qhY3JGZpT8ockkzdkTHahMJe177aE2dcyQ5CAn",
  render_errors: [view: LovelaceWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Lovelace.PubSub,
  live_view: [signing_salt: "XP1985o+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

config :lovelace, pubsub_channel: Lovelace.PubSub

config :lovelace, :bot_config,
  bot_id: 1_599_759_996,
  welcome_timeout: 40,
  ban_duration: :forever,
  after_success_message: "Obrigado por se cadastrar!",
  after_fail_message: "Usuário não se cadastrou, logo, foi banide.",
  welcome_message: """
  Olá, seja bem-vinde ao grupo de Ciência da Computação da UENF!
  Para validar sua participação, informe seu papel no curso.

  Caso não responda dentro de 40 segundos, você será banide, pois será identificade como um bot.
  """

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
