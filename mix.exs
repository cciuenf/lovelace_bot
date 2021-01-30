defmodule Lovelace.MixProject do
  use Mix.Project

  def project do
    [
      app: :lovelace,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Lovelace.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nadia, "~> 0.7.0"},
      {:poison, "~> 3.1"},
      {:tesla, "~> 1.4.0"},
      {:hackney, "~> 1.16.0"}
    ]
  end
end
