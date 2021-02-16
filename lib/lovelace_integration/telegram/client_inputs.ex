defmodule LovelaceIntegration.Telegram.ClientInputs do
  @moduledoc """
  Behaviour for inputs to the telegram bot api

  When used, defines a build function which casts to embedded, then casts to map
  removing nil fields
  """

  alias Lovelace.Changeset

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour LovelaceIntegration.Telegram.ClientInputs

      use Lovelace.Changeset

      @impl true
      def build(attrs) do
        case __MODULE__.cast(atts) do
          %Changeset{valid?: true} = changeset ->
            input_map =
              changeset
              |> Changeset.apply_changes()
              |> Map.from_struct()
              |> LovelaceIntegration.Telegram.ClientInputs.drop_nil()

            {:ok, input_map}

          changeset ->
            {:error, changeset}
        end
      end

      defoverridable(build: 1)
    end
  end

  @callback build(term()) :: {:ok, term()} | {:error, term()}
  @callback cast(term()) :: Changeset.t()

  def drop_nil(base) do
    base
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
