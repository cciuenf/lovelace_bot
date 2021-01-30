defmodule Lovelace.Helpers do
  use Tesla
  require Logger

  plug(Tesla.Middleware.JSON, engine: Poison)

  @doc """
  Return an args list as
  "/comand 1 2 3" -> [1, 2, 3]
  """
  def get_args(text) do
    [_c | args] =
      text
      |> String.split(" ")

    args
  end

  @doc """
  Takes entities in message body as argument,
  and returns a list of user_id that have been mentioned in message

  /kick @User_1 @User_2 -> 184564595 284564595
  """
  def get_mentioned_users(entities) do
    entites
    |> Enum.filter(&(&1.type == "text_mention"))
    |> Enum.mao(& &1.user.id)
  end

  # wrapper for string to int

  def digit_to_int(digit) do
    {number, _rest} =
      digit
      |> Integer.parse()

    number
  end

  # wrapper to parse Tesla responses

  def handle_response({:ok, %{status: 200, body: body}}), do: {:ok, body}
  def handle_response({:ok, %{status: _, body: _} = resp}), do: {:error, resp}
  def handle_response({:error, _error} = resp), do: resp

  # Challenges extraction

  def extract_challenges({:ok, body}, _number = "") do
    for item <- body, into: [] do
      ~s(#{item["name"]} - soluções: #{item["solutions"]} - #{item["link"]}\n)
    end
  end

  def extract_challenges({:ok, body}, number) do
    item =
      body
      |> Enum.at(digit_to_int(number))

    ~s(#{item["name"]} - soluções: #{item["solutions"]} - #{item["link"]}\n)
  end

  # Ranking extactions

  def extract_ranking({:ok, body}, _top = "") do
    for item <- body, into: [] do
      ~s(#{item["ranking"]} - soluções: #{item["user"]} - #{item["pontuation"]}\n)
    end
  end

  def extract_ranking({:ok, body}, top) do
    slice =
      body
      |> Enum.slice(0, digit_to_int(top))

    for item <- slice, into: [] do
      ~s(#{item["ranking"]} - soluções: #{item["user"]} - #{item["pontuation"]}\n)
    end
  end

  # XKCD extactions

  def extract_xkcd({:ok, body}), do: body["img"]

  def random_xkcd_number({:ok, body}), do: Enum.random(1..body["num"])

  # Joke extractions

  def extract_joke({:ok, body}, _number = "") do
    item = body |> Enum.random()

    ~s(#{item["joke"]})
  end

  def extract_joke({:ok, body}, number) do
    item = body |> Enum.at(digit_to_int(number))

    ~s(#{item["joke"]})
  end

  def get_ranking(top \\ "") do
    get("https://raw.githubusercontent.com/cciuenf/desafios/master/ranking.json")
    |> handle_response()
    |> extract_ranking(top)
  end

  def get_challenges(number \\ "") do
    get("https://raw.githubusercontent.com/cciuenf/desafios/master/challenges.json")
    |> handle_response()
    |> extract_challenges(number)
  end

  def get_joke(number \\ "") do
    get("https://raw.githubusercontent.com/cciuenf/lovelace_bot/master/jokes.json")
    |> handle_response()
    |> extract_joke(number)
  end

  def get_xkcd(_number = "") do
    get("https://xkcd.com/info.0.json")
    |> handle_response()
    |> random_xkcd_number()
    |> get_xkcd()
  end

  def get_xkcd(number) do
    get("https://xkcd.com/#{number}/info.0.json")
    |> handle_response()
    |> extract_xkcd()
  end
end
