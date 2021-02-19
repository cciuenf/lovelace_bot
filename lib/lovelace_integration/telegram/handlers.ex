defmodule LovelaceIntegration.Telegram.Handlers do
  @moduledoc """
  Behaviour for telegram message handlers.
  Also matches messages with handlers through get_handler/1
  """

  alias LovelaceIntegration.Telegram.{Callback, Message}
  alias LovelaceIntegration.Telegram.Handlers.{DefaultHandler, HelpHandler, NewUserHandler}

  @callback handle(Message.t()) :: {:ok, term()} | {:error, term()}

  @doc """
  Matches a message with its handler module
  """
  def get_hadler(%Message{user_id: user_id}) when not is_nil(user_id), do: {:ok, NewUserHandler}
  def get_handler(%Message{text: "/help" <> ""}), do: {:ok, HelpHandler}

  @doc """
  Matches a callback with its handler module
  """
  def get_handler(%Callback{data: "professor"}), do: {:ok, ProfessorHandler}
  def get_handler(%Callback{data: "student"}), do: {:ok, StudentHandler}

  def get_handler(_), do: {:ok, DefaultHandler}
end
