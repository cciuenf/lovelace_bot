defmodule LovelaceIntegration.Telegram.Handlers do
  @moduledoc """
  Behaviour for telegram message handlers.
  Also matches messages with handlers through get_handler/1
  """

  alias LovelaceIntegration.Telegram.{Callback, Message}

  alias LovelaceIntegration.Telegram.Handlers.{
    ChallengesHandler,
    DefaultHandler,
    HelpHandler,
    LeftMemberHandler,
    NewMemberHandler,
    RoleChangeHandler,
    UnkownHandler,
    UserHandler
  }

  @callback handle(Message.t() | Callback.t()) :: {:ok, term()} | {:error, term()}

  @doc """
  Matches a message with its handler module
  """
  def get_handler(%Message{text: "/ajuda"}), do: {:ok, HelpHandler}
  def get_handler(%Message{text: "/desafios"}), do: {:ok, ChallengesHandler}
  def get_handler(%Message{text: "/desafio" <> " " <> _}), do: {:ok, ChallengesHandler}
  def get_handler(%Message{text: "/promover" <> " " <> _}), do: {:ok, RoleChangeHandler}
  def get_handler(%Message{text: "/rebaixar" <> " " <> _}), do: {:ok, RoleChangeHandler}

  def get_handler(%Message{text: "new_user"}), do: {:ok, NewMemberHandler}
  def get_handler(%Message{text: "left_user"}), do: {:ok, LeftMemberHandler}

  def get_handler(%Message{text: "/" <> _}), do: {:ok, UnkownHandler}

  def get_handler(%Callback{}), do: {:ok, UserHandler}

  def get_handler(_), do: {:ok, DefaultHandler}
end
