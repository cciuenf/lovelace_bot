defmodule LovelaceIntegration.Telegram.Handlers.UserHandler do
  @moduledoc """
  Registers a user as a professor or a student
  """

  require Logger

  alias Lovelace.Accounts

  alias LovelaceIntegration.Telegram.{Callback, Client}
  @behaviour LovelaceIntegration.Telegram.Handlers

  @seconds_in_year 3_171 * 100 * 100 * 100 * 10

  @restrictions %{
    "can_send_messages" => true,
    "can_send_media_messages" => true,
    "can_send_polls" => true,
    "can_send_other_messages" => true,
    "can_add_web_page_previews" => true,
    "can_change_info" => true,
    "can_invite_users" => true,
    "can_pin_messages" => true
  }

  def handle(%Callback{data: "professor"} = cb) do
    case check_cb_ownership(cb) do
      {:ok, cb} ->
        Application.get_env(:lovelace, :timer_ref) |> captcha_solved()

        {username, full_name} = get_user_info(cb)

        msg_text = "O usuário #{username} passou no captcha e se registrou como Professor!"

        %{
          is_professor?: true,
          telegram_id: cb.user_id,
          telegram_username: username,
          full_name: full_name
        }
        |> Accounts.create_user()
        |> post_challenge(cb, msg_text)

      {:error, :other_user} ->
        %{
          chat_id: cb.chat_id,
          text: "Esse captcha não é para você..."
        }
        |> Client.send_message()
    end
  end

  def handle(%Callback{data: "student"} = cb) do
    case check_cb_ownership(cb) do
      {:ok, cb} ->
        Application.get_env(:lovelace, :timer_ref) |> captcha_solved()

        {username, full_name} = get_user_info(cb)

        msg_text = "O usuário #{username} passou no captcha e se registrou como Aluno!"

        %{
          is_professor?: false,
          telegram_id: cb.user_id,
          telegram_username: username,
          full_name: full_name
        }
        |> Accounts.create_user()
        |> post_challenge(cb, msg_text)

      {:error, :other_user} ->
        %{
          chat_id: cb.chat_id,
          text: "Esse captcha não é para você..."
        }
        |> Client.send_message()
    end
  end

  defp check_cb_ownership(%Callback{message: msg, from: from} = cb) do
    if msg.reply_to_message.from.id != from.id do
      Logger.info("A user not challenged solved the captcha...")

      {:error, :other_user}
    else
      Logger.info("The correct user solved the captcha!")

      {:ok, cb}
    end
  end

  defp post_challenge({:ok, _body}, cb, text) do
    %{
      chat_id: cb.chat_id,
      text: text
    }
    |> Client.send_message()
    |> unrestrict_user(cb)
  end

  defp post_challenge({:error, changeset} = error, cb, _text) do
    Logger.error("Error inserting user with id #{cb.user_id}")
    Logger.error("Error => #{inspect(changeset)}")

    error
  end

  defp unrestrict_user({:ok, _}, cb) do
    %{
      chat_id: cb.chat_id,
      user_id: cb.user_id,
      permissions: @restrictions,
      until_date: forever()
    }
    |> Client.restrict_user()
    |> case do
      {:ok, _} ->
        %{
          chat_id: cb.chat_id,
          message_id: cb.message.reply_to_message.message_id + 1
        }
        |> Client.delete_message()

      {:error, _reason} = error ->
        error
    end
  end

  defp unrestrict_user(error, _), do: error

  defp forever do
    DateTime.utc_now()
    |> DateTime.add(@seconds_in_year, :second)
    |> DateTime.to_unix()
  end

  defp get_user_info(cb) do
    first_name = cb.from.first_name || ""
    last_name = cb.from.last_name || ""

    full_name = first_name <> " " <> last_name

    username = cb.from.username || full_name

    {username, full_name}
  end

  defp captcha_solved(timer_ref), do: {:ok, :cancel} = :timer.cancel(timer_ref)
end
