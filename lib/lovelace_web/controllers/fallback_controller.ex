defmodule LovelaceWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use LovelaceWeb, :controller

  alias LovelaceWeb.ConnStatuses, as: StatusCode

  @accepts :any
  def call(conn, {:ok, message}) when is_atom(message), do: call(conn, {:ok, %{message: message}})

  def call(conn, {:ok, %{message: message} = body}) do
    conn
    |> StatusCode.put_status(message, :ok)
    |> put_view(LovelaceWeb.APISuccessView)
    |> assign(:body, body)
    |> render("success.json")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> put_view(LovelaceWeb.ErrorView)
    |> render("404.json")
  end

  def call(conn, {:error, message}) when is_atom(message),
    do: call(conn, {:error, %{message: message}})

  def call(conn, {:error, %{message: message} = body}) do
    conn
    |> StatusCode.put_status(message, :error)
    |> assign(:body, body)
    |> put_view(LovelaceWeb.APIErrorView)
    |> render("generic_error.json")
  end
end
