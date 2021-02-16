defmodule Lovelace.Repo do
  use Ecto.Repo,
    otp_app: :lovelace,
    adapter: Ecto.Adapters.Postgres
end
