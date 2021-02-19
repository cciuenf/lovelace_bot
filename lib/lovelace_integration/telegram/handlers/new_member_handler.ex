defmodule LovelaceIntegration.Telegram.Handlers.NewMemberHandler do
  @moduledoc """
  Restrict a new user to send messages and challenges it with a captcha
  """

  require Logger

  alias LovelaceIntegration.Telegram
  alias LovelaceIntegration.Telegram.{ChatMember, Client, Message}

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

  @captcha_countdown 40 * 1_000

  def handle(msg) do
    msg
    |> get_chat_member()
    |> restrict_user()
    |> challenge_user()
    |> start_countdown()
    |> case do
      {:ok, ref} ->
        Application.put_env(:lovelace, :timer_ref, ref)

        {:ok, :timer_set}

      _ ->
        {:error, :timer_error}
    end
  end

  defp get_chat_member(%Message{chat_id: c_id, user_id: u_id} = msg) do
    %{
      chat_id: c_id,
      user_id: u_id
    }
    |> Client.get_chat_member()
    |> case do
      {:ok, %{body: body}} ->
        {:ok, %ChatMember{status: status}} = body |> Telegram.build_chat_member()

        if status =~ "restricted" do
          Logger.info("User #{u_id} restricted in chat: #{c_id}")

          {:error, :already_restricted}
        else
          {:ok, msg}
        end

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

  defp challenge_user({:ok, %Message{chat_id: c_id, message_id: m_id} = msg}) do
    %{
      chat_id: c_id,
      text: welcome_text(),
      parse_mode: "HTML",
      reply_markup: @keyboard,
      reply_to_message_id: m_id
    }
    |> Client.send_message()
    |> case do
      {:ok, _} ->
        {:ok, msg}

      error ->
        error
    end
  end

  defp start_countdown({:error, _} = err), do: err

  defp start_countdown({:ok, %Message{chat_id: c_id, user_id: u_id}}) do
    params = %{
      chat_id: c_id,
      user_id: u_id,
      until_date: add_one_year()
    }

    :timer.apply_after(@captcha_countdown, Client, :ban_user, [params])
  end

  defp add_one_year do
    DateTime.utc_now()
    |> DateTime.add(@seconds_in_year, :second)
    |> DateTime.to_unix()
  end

  defp welcome_text, do: config_file_path() |> Toml.decode_file!() |> Map.get("welcome_message")

  defp config_file_path, do: Application.get_env(:lovelace, :config_path)
end
