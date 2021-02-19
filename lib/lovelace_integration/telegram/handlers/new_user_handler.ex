defmodule LovelaceIntegration.Telegram.Handlers.NewUserHandler do
  @moduledoc """
  Restrict a new user to send messages and challenges it with a captcha
  """

  require Logger

  alias LovelaceIntegration.Telegram.{Client, Message}
  @behaviour LovelaceIntegration.Telegram.Handlers

  @restrictions %{
    "can_send_messages" => false,
    "can_send_media_messages" => false,
    "can_send_polls" => false,
    "can_send_other_messages" => false,
    "can_add_web_page_previews" => false,
    "can_change_info" => false,
    "can_invite_users" => false,
    "can_pin_messages" => false
  }

  @keyboard %{
    "inline_keyboard" => [
      [
        %{
          "text" => "👩‍🏫 SOU PROFESSOR 👨‍🏫",
          "callback_data" => :professor
        },
        %{
          "text" => "👨‍🎓 SOU ALUNO 👩‍🎓",
          "callback_data" => :student
        }
      ]
    ]
  }

  @seconds_in_year 3_171 * 100 * 100 * 100 * 10

  def handle(msg) do
    msg
    |> get_chat_member()
    |> restrict_user()
    |> challenge_user()
  end

  defp get_chat_member(%Message{chat_id: c_id, user_id: u_id} = msg) do
    %{
      chat_id: c_id,
      user_id: u_id
    }
    |> Client.get_chat_member()
    |> case do
      {:ok, _} ->
        {:ok, msg}

      error ->
        error
    end
  end

  defp restrict_user({:error, _} = err), do: err

  defp restrict_user({:ok, %Message{chat_id: c_id, user_id: u_id} = msg}) do
    Logger.info("User #{u_id} joined the chat: #{c_id}")

    %{
      chat_id: c_id,
      user_id: u_id,
      permissions: @restrictions,
      until_date: add_one_year()
    }
    |> Client.restrict_user()
    |> case do
      {:ok, _} ->
        {:ok, msg}

      error ->
        error
    end
  end

  defp challenge_user({:error, _} = err), do: err

  defp challenge_user({:ok, %Message{chat_id: c_id, message_id: m_id}}) do
    %{
      chat_id: c_id,
      text: welcome_text(),
      parse_mode: "HTML",
      reply_markup: @keyboard,
      reply_to_message_id: m_id
    }
    |> Client.send_message()
  end

  defp add_one_year, do: DateTime.utc_now() |> DateTime.add(@seconds_in_year, :second)

  defp welcome_text, do: config_file_path() |> Toml.decode_file!() |> Map.get("welcome_message")

  defp config_file_path, do: Application.get_env(:lovelace, :config_path)
end
