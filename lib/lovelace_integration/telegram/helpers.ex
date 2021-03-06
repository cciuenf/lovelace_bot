defmodule LovelaceIntegration.Telegram.Helpers do
  @moduledoc """
  Provide helper functioons to handle commands
  """

  use Tesla
  require Logger

  alias Lovelace.Accounts

  plug Tesla.Middleware.Headers
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  @doc """
  Return an args list as
  "/comand 1 2 3" -> [1, 2, 3]
  """
  def get_args(text) do
    [_c | args] =
      text
      |> String.split(" ")

    args
    |> Enum.join(" ")
  end

  @doc """
  Takes entities in message body as argument,
  and returns a list of user_id that have been mentioned in message
  /kick @User_1 @User_2 -> 184564595 284564595
  """
  def get_mentioned_users_ids(mentions) do
    mentions
    |> Enum.map(&String.replace(&1, "@", ""))
    |> Enum.map(fn mention ->
      {:ok, user} = Accounts.get_user_by(username: mention)

      user.telegram_id
    end)
  end

  @doc """
  Parses string digits to integers
  """
  def digit_to_int(digit) do
    {number, _rest} =
      digit
      |> Integer.parse()

    number
  end

  @doc """
  Wraps Tesla responses
  """
  def handle_response({:ok, %{status: 200, body: body}}), do: {:ok, body}
  def handle_response({:ok, resp = %{status: _, body: _}}), do: {:error, resp}
  def handle_response(resp = {:error, _error}), do: resp

  @doc """
  Given the challenges file and a optional ranking position,
  returns a parsed message.
  """
  def extract_challenges({:ok, body}, _number = "") do
    for item <- body, into: "" do
      ~s(#{item["name"]} - soluções: #{item["solutions"]} - #{item["link"]}\n)
    end
  end

  def extract_challenges({:ok, body}, number) do
    item =
      body
      |> Enum.at(digit_to_int(number))

    ~s(#{item["name"]} - soluções: #{item["solutions"]} - #{item["link"]}\n)
  end

  @doc """
  Given the ranking file and a optional ranking position,
  returns a parsed message.
  """
  def extract_ranking({:ok, body}, _top = "") do
    for item <- body, into: "" do
      ~s(#{item["ranking"]} - soluções: #{item["user"]} - #{item["pontuation"]}\n)
    end
  end

  def extract_ranking({:ok, body}, top) do
    slice =
      body
      |> Enum.slice(0, digit_to_int(top))

    for item <- slice, into: "" do
      ~s(#{item["ranking"]} - soluções: #{item["user"]} - #{item["pontuation"]}\n)
    end
  end

  @doc """
  Gets the ranking file and then parses response
  """
  def get_ranking(top \\ "") do
    get("https://raw.githubusercontent.com/cciuenf/desafios/main/ranking.json")
    |> handle_response()
    |> extract_ranking(top)
  end

  @doc """
  Gets the challenges file and then parses response
  """
  def get_challenges(number \\ "") do
    get("https://raw.githubusercontent.com/cciuenf/desafios/main/challenges.json")
    |> handle_response()
    |> extract_challenges(number)
  end
end
