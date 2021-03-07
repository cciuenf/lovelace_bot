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

    Case você seja um professor, todos os comandos podem ser executados!

    Veja algumas delas:

    <b>Se você for um professor</b>
    1. /listar -> lista todos os alunos cadastrados
    WIP...

    <b>Se voê for um admin</b>
    1. /promover <menções> -> promove um ou mais usuaŕios
    2. /rebaixar <menções> -> rebaixa um ou mais usuaŕios
    3. /banir <menções> -> bane um ou mais usuários
    4. /verificar -> mostra um pequeno relatório do grupo

    <b>Se você for aluno</b>
    1. /ajuda -> mostra essa mensagem
    2. /agenda -> mostra os próximos eventos do curso (WIP...)
    3. /desafios -> lista todos os desafios da Lovelace
    4. /desafio <número> -> mostra apenas um desafio
    5. /ranking -> mostra o ranking geral dos desafios
    6. /ranking <número> -> mostra os primeiros N desafiantes
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
