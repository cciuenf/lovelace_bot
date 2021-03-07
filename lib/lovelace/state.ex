defmodule Lovelace.State do
  @moduledoc """
  An Agent to store global state
  """

  use Agent

  @initial_state %{}

  @doc """
  Creates a new state, with a initial value
  """
  def start_link(opts) do
    Agent.start_link(fn -> @initial_state end, opts)
  end

  @doc """
  Retrieves a value from the state
  """
  def get(key) when is_atom(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  @doc """
  Inserts a new value on the state, given a key
  """
  def put(key, value) when is_atom(key) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  @doc """
  Updates a value of state, given a key
  """
  def update(key, value) when is_atom(key) do
    Agent.get_and_update(__MODULE__, &Map.update(&1, key, value, fn _ -> value end))
  end

  @doc """
  Removes a value from the state, given your key
  """
  def delete(key) when is_atom(key) do
    Agent.get_and_update(__MODULE__, &(Map.pop(&1, key) |> Tuple.delete_at(0)))
  end
end
