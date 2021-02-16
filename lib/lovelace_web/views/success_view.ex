defmodule LovelaceWeb.SuccessView do
  use LovelaceWeb, :view

  def render("success.json", %{body: body}) do
    body
  end
end
