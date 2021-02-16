defmodule LovelaceWeb.APIErrorView do
  use LovelaceWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("generic_error.json", %{body: body}) do
    body
  end

  def render("404.json", _) do
    %{message: "not_found"}
  end

  def render("500.json", _assigns) do
    %{message: "internal_server_error"}
  end
end
