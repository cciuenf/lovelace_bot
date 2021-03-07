defmodule Lovelace.State do
  @moduledoc """
  An Agent to store global state
  """

  use Agent

  @initial_state %{}

  @doc """
  Creates a new state, with a initial value, given a name

  Default initial state is an empty map `%{}`

  For this case, this module only accepts initial states that are maps

  You can also use all `Agent` native functions to use other initial states

  ## Examples

     iex> State.start_link(:state, initial_state: 4)
     {:ok, pid()}

     iex> State.start_link(:state2)
     {:ok, pid()}
  """
  def start_link(name, opts \\ []) do
    {initial_state, opts} = Keyword.pop(opts, :initial_state, @initial_state)

    initial_state =
      if is_map(initial_state),
        do: initial_state,
        else: @initial_state

    Agent.start_link(fn -> initial_state end, opts ++ [name: name])
  end

  @doc """
  Retrieves a value from a existing state

  ## Examples

     iex> State.get(state, :key)
     any()

     iex> State.get(state, :invalid_key)
     nil
  """
  def get(state, key) when is_atom(key) do
    Agent.get(state, &Map.get(&1, key))
  end

  @doc """
  Retrieves the whole state

  ## Examples

     iex> State.get_all(state)
     map()
  """
  def get_all(state) do
    Agent.get(state, & &1)
  end

  @doc """
  Inserts a new key with a value on a given state

  Key must be an atom!

  ## Examples

     iex> State.put(state, :key, value)
     :ok
  """
  def put(state, key, value) when is_atom(key) do
    Agent.update(state, Map, :put, [key, value])
  end

  @doc """
  Updates value of a key, given a state

  If key does not exist, it'll be created

  ## Examples

     iex> State.update(state, :key, value)
     :ok

     iex> State.update(state, :invalid_key, value)
     :ok
  """
  def update(state, key, value) when is_atom(key) do
    Agent.get_and_update(state, &Map.update(&1, key, value, fn _ -> value end))
  end

  @doc """
  Removes a value from a given state
  """
  def delete(state, key) when is_atom(key) do
    Agent.get_and_update(state, Map, :delete, [key])
  end

  @doc """
  Stops and kills a existing state

  ## Examples

     iex> State.kill(state)
     :killed
  """
  def kill(state) do
    Agent.stop(state, :killed)
  end
end
