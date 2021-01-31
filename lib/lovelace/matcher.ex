defmodule Lovelace.Matcher do
  @moduledoc """
  Here is where the commands are dispatched
  """

  use GenServer

  alias Lovelace.Commands

  # Server

  def start_link(_state) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(message, state) do
    message
    |> Commands.match_message()

    {:noreply, state}
  end

  # Client

  def match(message) do
    GenServer.cast(__MODULE__, message)
  end
end
