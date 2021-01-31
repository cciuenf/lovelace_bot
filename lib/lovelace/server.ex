defmodule Lovelace.Server do
  @moduledoc """
  This module only exists because Heroku and Google Cloud needs to bind a port...
  I really don't know if exists a better way.

  I only need to do this because I ain't using web hooks! If it was the case,
  I would be using Phoenix so it would have its own built in server.
  """

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello World!\n")
  end
end
