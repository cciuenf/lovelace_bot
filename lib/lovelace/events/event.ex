defmodule Lovelace.Events.Event do
  @moduledoc """
  Defines an event which will be consumed by the pipeline.

  Should implement a callback that defines the topic and
  a callback that defines the coercion function it will be
  cast through
  """

  @optional_callbacks topic: 0

  @doc """
  Topic for this event, will be matched against incoming publishing attempts
  """
  @callback topic(term) :: String.t()
  @callback topic :: String.t()

  @doc """
  Casts the payload
  """
  @callback cast(term) :: {:ok, term()} | {:error, reason :: atom()}
end
