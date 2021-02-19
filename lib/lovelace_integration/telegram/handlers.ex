defmodule LovelaceIntegration.Telegram.Handlers do
  @moduledoc """
  Behaviour for telegram message handlers.
  Also matches messages with handlers through get_handler/1
  """

  alias LovelaceIntegration.Telegram.Message
  alias LovelaceIntegration.Telegram.Handlers.{DefaultHandler, HelpHandler, NewUserHandler}

  @callback handle(Message.t()) :: {:ok, term()} | {:error, term()}

  @doc """
  Matches a message with its handler module
  """
  def get_hadler(%Message{user_id: user_id}) when not is_nil(user_id), do: {:ok, NewUserHandler}
  def get_handler(%Message{text: "/help" <> ""}), do: {:ok, HelpHandler}
  def get_handler(_), do: {:ok, DefaultHandler}
end
