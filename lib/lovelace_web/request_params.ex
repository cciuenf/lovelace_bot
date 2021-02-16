defmodule LovelaceWeb.RequestParams do
  @moduledoc """
  Used to filter which params a controller function will accept.
  Every controller must use this to avoid param injection.

  Usage:

  Before every public function on a controller, you must define @accepts containing the respective filters for that route.
  E.g.:

  @accepts [:name, :age, :profession] \n
  def create(conn, params) do \n
    [...]\n
  end\n

  You don't need to do this on multiple clauses of the same function, private functions or macros.
  """

  def __on_definition__(_env, _kind, :action, _args, _guards, _body), do: nil

  def __on_definition__(env, :def, name, args, _guards, _body) do
    module = env.module

    defined = {name, args |> Enum.count()}

    module
    |> Module.get_attribute(:__last_defined_acceptance__)
    |> Kernel.==(defined)
    |> unless do
      put_accepted(module, name)

      Module.put_attribute(module, :__last_defined_acceptance__, defined)
      Module.delete_attribute(module, :accepts)
    end
  end

  def __on_definition__(_env, _kind, _name, _args, _guards, _body), do: nil

  defmacro __before_compile__(_env) do
    quote do
      @accepts :any
      def action_params(action) do
        @__accepted_params__
        |> Keyword.get(action)
        |> case do
          nil -> :any
          list -> list |> Enum.map(&Atom.to_string/1)
        end
      end

      @accepts :any
      def __take_params__(%Plug.Conn{params: params} = conn, _) do
        action = conn |> action_name()

        @__accepted_params__
        |> Keyword.get(action)
        |> case do
          :no_param -> %{conn | params: %{}}
          nil -> conn
          list -> %{conn | params: params |> Map.take(list |> Enum.map(&Atom.to_string/1))}
        end
      end
    end
  end

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :__accepted_params__, accumulate: true)

      plug :__take_params__

      @on_definition LovelaceWeb.RequestParams
      @before_compile LovelaceWeb.RequestParams

      @__last_defined_acceptance__ {nil, nil}
    end
  end

  defp put_accepted(module, name) do
    module
    |> Module.get_attribute(:accepts)
    |> case do
      value when is_list(value) ->
        Module.put_attribute(module, :__accepted_params__, {name, value})

      :any ->
        nil

      nil ->
        raise "You must define @accepts before #{name}/2 to protect the database from undesired params"

      :no_param ->
        :no_param

      value ->
        raise "@accepts must be from type [atom()], or :any if params are not to be filtered, got: #{
                inspect(value)
              }"
    end
  end
end
