defmodule LovelaceIntegration.Telegram.Helpers do
  @moduledoc """
  Provide helper functioons to handle commands
  """

  use Tesla
  require Logger

  alias Lovelace.Accounts
  alias LovelaceIntegration.Telegram.Client

  plug Tesla.Middleware.Headers
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger

  @seconds_in_year 3_171 * 100 * 100 * 100 * 10

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
  def get_mentioned_users(mentions) do
    mentions
    |> Enum.map(&String.replace(&1, "@", ""))
    |> Enum.map(fn mention ->
      Accounts.get_user_by(username: mention)
      |> Tuple.append(mention)
    end)
  end

  @doc """
  Check if it's a valid mention
  """
  def parse_mentions(mentions, msg) do
    mentions
    |> Enum.filter(fn mention ->
      if mention =~ "@" do
        true
      else
        %{
          chat_id: msg.chat_id,
          text: ~s(Você precisa mencionar o usuário com um "@"),
          reply_to_message_id: msg.message_id
        }
        |> Client.send_message()

        false
      end
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
  Returns a "forever" timestamp
  """
  def forever do
    DateTime.utc_now()
    |> DateTime.add(@seconds_in_year, :second)
    |> DateTime.add(@seconds_in_year, :second)
    |> DateTime.to_unix()
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

    offset = digit_to_int(top)

    slice =
      ranking
      |> Enum.slice(0, offset)

    base =
      if length(body) < offset,
        do: base <> "Não existem tantos participantes assim...\n\n",
        else: base

    base = base <> "Mostrando os #{length(slice)} primeiros usuários\n\n"

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
