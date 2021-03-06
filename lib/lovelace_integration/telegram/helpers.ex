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
  def handle_response({:ok, %{status: 200, body: body}}), do: {:ok, Jason.decode!(body)}
  def handle_response({:ok, resp = %{status: _, body: _}}), do: {:error, resp}
  def handle_response(resp = {:error, _error}), do: resp

  @doc """
  Given the challenges file and a optional ranking position,
  returns a parsed message.
  """
  def extract_challenges({:ok, body}, _number = "") do
    base = ~s"""
    <b>Desafios da Lovelace</b>

    Aqui estão os desafios existentes:

    """

    res =
      for {item, index} <- Enum.with_index(body), into: base do
        link = ~s(<a href="#{item["link"]}">desafio #{index + 1}</a>)

        ~s"""
        <b>#{item["name"]}</b>
        Soluções: #{item["solutions"]}
        Link: #{link}


        """
      end

    {:ok, res}
  end

  def extract_challenges({:ok, body}, number) do
    number = digit_to_int(number)

    if number > length(body) do
      {:error, "Esse desafio não existe"}
    else
      item =
        body
        |> Enum.at(number)

      res = ~s"""
      <b>#{item["name"]}</b>
      Soluções: #{item["solutions"]}
      Link: #{item["link"]}

      """

      {:ok, res}
    end
  end

  @doc """
  Given the ranking file and a optional ranking position,
  returns a parsed message.
  """
  def extract_ranking({:ok, body}, _top = "") do
    base = ~s"""
    <b>Ranking geral dos desafios da Lovelace</b>

    """

    ranking = body |> Enum.sort_by(& &1["pontuation"]) |> Enum.with_index()

    for {item, position} <- ranking, into: base do
      ~s"""
      <b>#{position + 1}º lugar</b>
      Usuário: #{item["user"]}
      Pontuação: #{item["pontuation"]}

      """
    end
  end

  def extract_ranking({:ok, body}, top) do
    base = ~s"""
    <b>Ranking relativo dos desafios da Lovelace</b>

    """

    ranking = body |> Enum.sort_by(& &1["pontuation"]) |> Enum.with_index()

    slice =
      ranking
      |> Enum.slice(0, digit_to_int(top))

    base = base <> "Mostrando os #{length(slice)} primeiros usuários"

    for {item, position} <- slice, into: base do
      ~s"""
      <b>#{position + 1}º lugar</b>
      Usuário: #{item["user"]}
      Pontuação: #{item["pontuation"]}

      """
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
