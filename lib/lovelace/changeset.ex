defmodule Lovelace.Changeset do
  @moduledoc """
  Ecto.Changeset extension with a few more functions
  """

  import Lovelace.Common.Wrapping

  defmacro __using__(opts \\ []) do
    quote do
      import Ecto.Changeset
      import Lovelace.Changeset

      if unquote(opts[:command]) do
        def maybe_execute_command(changeset, command_list, command) do
          if command in command_list do
            execute_command(changeset, command)
          else
            changeset
          end
        end
      end
    end
  end

  import Ecto.Changeset

  ###### Helpers ######

  @doc """
  Removes whitespaces from a string

  An example input could be " Jose  Silva  ", which would return "Jose Silva"
  """
  def remove_whitespaces(changeset, field) do
    update_if_changed(changeset, field, fn value ->
      value
      |> String.replace(~r/\s+/, " ")
      |> String.trim(" ")
    end)
  end

  @doc """
  Capitalizes all words on a given field

  An example input could be "matheus PESSANHA", which would return "Matheus Pessanha"
  """
  def capitalize_all_words(changeset, field) do
    update_if_changed(changeset, field, fn value ->
      value
      |> String.split(" ")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")
    end)
  end

  @doc """
  Downcases a field

  An example input could be "Puddington@Gmail.com", which would return "puddington@gmail.com"
  """
  def downcase(changeset, field) do
    update_if_changed(changeset, field, &String.downcase(&1))
  end

  ###### Validations ######

  @doc """
  Validates if the comparison two time fields follows the criteria
  """
  def validate_time_comparison(changeset, [_, _] = fields, operator) do
    validate_time_family_comparison(changeset, fields, operator, Time)
  end

  @doc """
  Validates if the comparison of two date fields follows the criteria
  """
  def validate_date_comparison(changeset, [_, _] = fields, operator) do
    validate_time_family_comparison(changeset, fields, operator, Date)
  end

  @doc """
  Validates if the comparison of two datetime fields follows the criteria
  """
  def validate_datetime_comparison(changeset, [_, _] = fields, operator) do
    validate_time_family_comparison(changeset, fields, operator, NaiveDateTime)
  end

  @operator_errors %{
    !=: "should not be equal %{field}",
    ==: "should be equal to %{field}",
    >=: "should be equal or greater than %{field}",
    <=: "should be equal or less than %{field}",
    >: "should be greater than %{field}",
    <: "should be less than %{field}"
  }
  defp validate_time_family_comparison(changeset, [_, _] = fields, operator, type) do
    maybe_compare_fields(changeset, fields, fn ->
      (&type.compare/2)
      |> apply(fields |> Enum.map(&get_field(changeset, &1)))
      |> case do
        :eq when operator in [:==, :>=, :<=] -> :ok
        :gt when operator in [:!=, :>, :>=] -> :ok
        :lt when operator in [:!=, :<, :<=] -> :ok
        _ -> :error
      end
      |> case do
        :ok ->
          changeset

        _ ->
          [field1, field2] = fields

          changeset
          |> add_error(
            field1,
            @operator_errors[operator] |> String.replace("%{field}", "#{field2}")
          )
      end
    end)
  end

  # -----------------------

  def group_form_errors(changeset) do
    traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def default_error_response(changeset) do
    %{message: :form_error, details: group_form_errors(changeset)}
    |> error_wrap()
  end

  defp maybe_compare_fields(changeset, fields, function) do
    if fields |> Enum.any?(&(changeset |> get_change(&1, :unchanged) != :unchanged)),
      do: function.(),
      else: changeset
  end

  defp update_if_changed(changeset, field, fun) do
    changeset
    |> get_change(field)
    |> case do
      nil ->
        changeset

      value ->
        put_change(changeset, field, fun.(value))
    end
  end
end
