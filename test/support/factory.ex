defmodule Lovelace.Factory do
  @moduledoc """
  Factories for Lovelace's entities
  """

  use ExMachina.Ecto, repo: Lovelace.Repo

  alias Lovelace.Accounts.User

  def user_factory do
    %User{
      full_name: sequence(:name, &"Maria#{&1}"),
      telegram_id: sequence(:id, fn x -> "12#{x}34" |> String.to_integer() end),
      telegram_username: sequence(:username, &"malu#{&1}")
    }
  end

  def professor_factory do
    %User{
      full_name: sequence(:name, &"Prof#{&1}"),
      telegram_id: sequence(:id, fn x -> "34#{x}56" |> String.to_integer() end),
      telegram_username: sequence(:username, &"prof#{&1}"),
      role: :professor
    }
  end

  def student_factory do
    %User{
      full_name: sequence(:name, &"Stude#{&1}"),
      telegram_id: sequence(:id, fn x -> "78#{x}910" |> String.to_integer() end),
      telegram_username: sequence(:username, &"stude#{&1}"),
      role: :student
    }
  end
end
