defmodule LovelaceIntegration.Telegram.Handlers do
  @moduledoc """
  Behaviour for telegram message handlers.
  Also matches messages with handlers through get_handler/1
  """

  alias LovelaceIntegration.Telegram.{Callback, Message}

  alias LovelaceIntegration.Telegram.Handlers.{
    AgendaHandler,
    BanHandler,
    ChallengesHandler,
    DefaultHandler,
    HelpHandler,
    LeftMemberHandler,
    ListHandler,
    NewMemberHandler,
    RankingHandler,
    RoleChangeHandler,
    UnkownHandler,
    UserHandler,
    VerifyHandler
  }

  @callback handle(Message.t() | Callback.t()) :: {:ok, term()} | {:error, term()}

  @doc """
  Matches a message with its handler module
  """
  def get_handler(%Message{text: "/ajuda"}), do: {:ok, HelpHandler}
  def get_handler(%Message{text: "/listar"}), do: {:ok, ListHandler}
  def get_handler(%Message{text: "/agenda"}), do: {:ok, AgendaHandler}
  def get_handler(%Message{text: "/verificar"}), do: {:ok, VerifyHandler}
  def get_handler(%Message{text: "/desafios"}), do: {:ok, ChallengesHandler}
  def get_handler(%Message{text: "/ranking" <> _}), do: {:ok, RankingHandler}
  def get_handler(%Message{text: "/banir" <> " " <> _}), do: {:ok, BanHandler}
  def get_handler(%Message{text: "/desafio" <> " " <> _}), do: {:ok, ChallengesHandler}
  def get_handler(%Message{text: "/promover" <> " " <> _}), do: {:ok, RoleChangeHandler}
  def get_handler(%Message{text: "/rebaixar" <> " " <> _}), do: {:ok, RoleChangeHandler}

  def get_handler(%Message{text: "new_user"}), do: {:ok, NewMemberHandler}
  def get_handler(%Message{text: "left_user"}), do: {:ok, LeftMemberHandler}

  def get_handler(%Message{text: "/" <> _}), do: {:ok, UnkownHandler}

  def get_handler(%Callback{}), do: {:ok, UserHandler}

  def get_handler(_), do: {:ok, DefaultHandler}
end
