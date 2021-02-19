defmodule LovelaceIntegration.Telegram.Consumers.CallbackHandler do
  @moduledoc """
  Stateless GenServer that subscribes to telegram callbacks and
  does something if they require an action
  """
  use GenServer

  require Logger

  alias Lovelace.Events
  alias LovelaceIntegration.Telegram
  alias LovelaceIntegration.Telegram.Callback

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  @impl true
  def init(_) do
    Logger.info("Starting #{__MODULE__}")

    Phoenix.PubSub.subscribe(
      Application.get_env(:lovelace, :pubsub_channel),
      Events.TelegramCallback.topic()
    )

    {:ok, nil}
  end

  @impl true
  def handle_info(
        %Callback{} = callback,
        state
      ) do
    Logger.info("#{__MODULE__} handling callback")
    # fire and forget, and don't make our genserver stuck
    Task.async(fn -> Telegram.process_callback(callback) end)

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
