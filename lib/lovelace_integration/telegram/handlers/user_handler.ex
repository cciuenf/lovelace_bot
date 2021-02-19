defmodule LovelaceIntegration.Telegram.Handlers.UserHandler do
  @moduledoc """
  Registers a user as a professor or a student
  """

  require Logger

  alias Lovelace.Accounts

  alias LovelaceIntegration.Telegram.{Callback, Client}
  @behaviour LovelaceIntegration.Telegram.Handlers

  def handle(%Callback{data: "professor", chat_id: c_id} = cb) do
    Application.get_env(:lovelace, :timer_ref) |> captcha_solved()

    %{"username" => username, "first_name" => first_name} = cb["from"]

    %{
      is_professor?: true,
      telegram_id: cb["user_id"],
      telegram_username: username,
      first_name: first_name
    }
    |> Accounts.create_user()
    |> case do
      {:ok, _user} ->
        %{
          chat_id: c_id,
          text: "O usuário #{username} passou no captcha e se registrou como Professor!"
        }
        |> Client.send_message()

      {:error, changeset} = error ->
        Logger.error(~s|Error inserting user with id #{cb["user_id"]}|)
        Logger.error("Error => #{inspect(changeset)}")

        error
    end
  end

  def handle(%Callback{data: "student"}) do
    Application.get_env(:lovelace, :timer_ref) |> captcha_solved()

    %{"username" => username, "first_name" => first_name} = cb["from"]

    %{
      is_professor?: false,
      telegram_id: cb["user_id"],
      telegram_username: username,
      first_name: first_name
    }
    |> Accounts.create_user()
    |> case do
      {:ok, _user} ->
        %{
          chat_id: c_id,
          text: "O usuário #{username} passou no captcha e se registrou como Aluno!"
        }
        |> Client.send_message()

      {:error, changeset} = error ->
        Logger.error(~s|Error inserting user with id #{cb["user_id"]}|)
        Logger.error("Error => #{inspect(changeset)}")

        error
    end
  end

  defp captcha_solved(timer_ref), do: {:ok, :cancel} = :timer.cancel(timer_ref)
end
