defmodule LovelaceIntegration.Telegram.Handlers.HelpHandler do
  @moduledoc """
  Sends a simple help message
  """

  alias LovelaceIntegration.Telegram.{Client, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def help do
    """
    Olá! Sou a lovelace_bot e estou aqui para te ajudar!

    Dependendo do seu papel no grupo, posso realizar diferentes tarefas!

    Veja algumas delas:

    <b>Se você for um professor</b>
    1. /listar -> lista todos os alunos cadastrados
    WIP...

    <b>Se você for aluno</b>
    WIP...
    """
  end

  def handle(%Message{chat_id: c_id, message_id: m_id}) do
    %{
      chat_id: c_id,
      parse_mode: "HTML",
      reply_to_message_id: m_id,
      text: help()
    }
    |> Client.send_message()
  end
end
