defmodule Lovelace.Schema do
  @moduledoc """
  This is a helper module to avoid some of the UUID boilerplate
  """

  import Ecto.Query

  defmacro __using__(opts \\ []) do
    quote do
      use Ecto.Schema
      import Ecto.Query
      import Lovelace.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      if unquote(opts[:expose]) do
        @exposed Module.get_attribute(__MODULE__, :exposed_fields, [])

        def exposed_fields, do: @exposed

        defp define_columns(query, nil), do: query

        defp define_columns(query) do
          query
          |> select([x], map(x, ^@exposed))
        end
      end

      if unquote(opts[:query]) do
        @sortings Module.get_attribute(__MODULE__, :simple_sortings, [])
        @filters Module.get_attribute(__MODULE__, :simple_filters, [])

        # Pagination
        defp put_limit(query, nil), do: query
        defp put_limit(query, limit), do: query |> limit(^limit)

        defp put_offset(query, nil), do: query
        defp put_offset(query, offset), do: query |> offset(^offset)

        # Querying

        @doc """
        Returns a query with params
        """
        @spec get_query(list({atom(), any()}) | nil) :: Ecto.Query.t()
        def get_query(params) do
          sort = params[:sort] || [asc: :inserted_at]

          from(x in __MODULE__)
          |> apply_filters(params)
          |> define_columns(params[:field_set])
          |> put_limit(params[:limit])
          |> put_offset(params[:offset])
          |> put_sort(sort)
        end

        # Filtering
        defp apply_filters(query, nil), do: query
        defp apply_filters(query, []), do: query

        defp apply_filters(query, [{field, :invalid} | _rest]) when field in @filters do
          query
          |> where([x], false)
        end

        defp apply_filters(query, [{field, value} | rest]) when field in @filters do
          query
          |> where([x], field(x, ^field) == ^value)
          |> apply_filters(rest)
        end

        defp apply_filters(query, [_ | rest]), do: apply_filters(query, rest)

        # Sorting
        defp put_sort(query, [{order, field}]) when field in @sortings do
          query
          |> order_by([a], {^order, ^field})
        end

        defp put_sort(query, _), do: query |> order_by([x], {:asc, x.inserted_at})
      end
    end
  end
end
