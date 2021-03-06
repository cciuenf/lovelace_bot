defmodule LovelaceIntegration.Telegram.Client do
  @moduledoc """
  Client for the telegram API
  """

  use Tesla

  alias LovelaceIntegration.Telegram.ClientInputs

  defp bot_token, do: Application.get_env(:lovelace, __MODULE__)[:bot_token]

  plug Tesla.Middleware.BaseUrl, "https://api.telegram.org/bot#{bot_token()}"
  plug Tesla.Middleware.Headers
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  @doc """
  Calls the sendMessage method in the telegram api
  """
  def send_message(params) do
    build_and_send(&post/2, "/sendMessage", ClientInputs.SendMessage, params)
  end

  @doc """
  Calls the restrictChatMember method in the telegram api
  """
  def restrict_user(params) do
    build_and_send(&post/2, "/restrictChatMember", ClientInputs.RestrictUser, params)
  end

  @doc """
  Calls the getChatMember method in the telegram api
  """
  def get_chat_member(params) do
    build_and_send(&post/2, "/getChatMember", ClientInputs.GetChatMember, params)
  end

  @doc """
  Calls the kickChatMember method in the telegram api
  """
  def ban_user(params) do
    build_and_send(&post/2, "/kickChatMember", ClientInputs.KickChatMember, params)
  end

  @doc """
  Calls the deleteMessage method in the telegram api
  """
  def delete_message(params) do
    build_and_send(&post/2, "/deleteMessage", ClientInputs.DeleteMessage, params)
  end

  @doc """
  Calls the getChatMembersCount in the telegram api
  """
  def get_group_members_count(params) do
    build_and_send(&post/2, "/getChatMembersCount", ClientInputs.GroupMembersCount, params)
  end

  @doc """
  Sends a message saying that the user had requested
  a action that's outside of his scope
  """
  def unauthenticated(msg) do
    %{
      chat_id: msg.chat_id,
      text: "Você não têm permissões suficientes para executar esse comando...",
      reply_to_message_id: msg.message_id
    }
    |> send_message()
  end

  @doc """
  Sends a message sayingthat the mentioned user does not exist
  """
  def dont_exist(msg, mention) do
    %{
      chat_id: msg.chat_id,
      text: ~s(O usuário "#{mention}" não foi encontrado...),
      reply_to_message_id: msg.message_id
    }
    |> send_message()
  end

  defp build_and_send(fun, route, module, params) do
    {:ok, input} = params |> module.build()

    route
    |> fun.(input)
  end
end
