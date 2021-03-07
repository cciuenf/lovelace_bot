defmodule LovelaceIntegration.Telegram.Handlers.NewMemberHandler do
  @moduledoc """
  Restrict a new user to send messages and challenges it with a captcha
  """

  require Logger

  alias Lovelace.State
  alias LovelaceIntegration.Telegram
  alias LovelaceIntegration.Telegram.{ChatMember, Client, Helpers, Message}

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

  @bot_id Application.compile_env(:lovelace, :bot_config)[:bot_id]

  @captcha_countdown 40 * 1_000

  def handle(%Message{new_chat_member: nm} = msg) when nm.id != @bot_id do
    msg
    |> get_chat_member()
    |> restrict_user()
    |> challenge_user()
    |> start_countdown()
    |> case do
      {:ok, ref} ->
        State.put(:timer_ref, ref)

        {:ok, :timer_set}

      _ ->
        {:error, :timer_error}
    end
  end

  def handle(_) do
    Logger.info("Lovelace Bot joined in a group!")

    {:ok, :lovelace_joined}
  end

  defp get_chat_member(%Message{chat_id: c_id, user_id: u_id} = msg) do
    %{
      chat_id: c_id,
      user_id: u_id
    }
    |> Client.get_chat_member()
    |> case do
      {:ok, %{body: body}} ->
        {:ok, %ChatMember{status: status}} = body["result"] |> Telegram.build_chat_member()

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

    restrict_time = restrict_time()

    %{
      chat_id: c_id,
      user_id: u_id,
      permissions: @restrictions,
      until_date: restrict_time
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
      {:ok, %{body: body}} ->
        State.put(:message_id, body["result"]["message_id"])

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
      until_date: Helpers.forever()
    }

    {:ok, ref} = :timer.apply_after(@captcha_countdown, Client, :ban_user, [params])

    {:ok, ref}
  end

  defp restrict_time do
    config_ban_time = Application.get_env(:lovelace, :bot_config)[:ban_duration]

    cond do
      config_ban_time == :forever ->
        Helpers.forever()

      is_integer(config_ban_time) and config_ban_time > 0 ->
        DateTime.utc_now()
        |> DateTime.add(config_ban_time * 60, :second)
        |> DateTime.to_unix()

      true ->
        Helpers.forever()
    end
  end

  defp welcome_text, do: Application.get_env(:lovelace, :bot_config)[:welcome_message]
end
