defmodule LovelaceTest do
  use ExUnit.Case
  doctest Lovelace

  test "greets the world" do
    assert Lovelace.hello() == :world
  end
end
