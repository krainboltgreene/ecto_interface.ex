defmodule EctoInterface.Read.Get do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural, singular])
           when is_atom(plural) and is_atom(singular) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns all `#{unquote(schema)}` with the matching primary keys
      """
      @spec unquote(:"get_#{plural}")(list(String.t())) :: list(unquote(schema).t())
      def unquote(:"get_#{plural}")([]), do: []

      def unquote(:"get_#{plural}")(ids),
        do: from(table in unquote(schema), where: table.id in ^ids) |> Application.get_env(:ecto_interface, :default_repo).all()

      @doc """
      Returns a singular `#{unquote(schema)}` with the matching properties
      """
      @spec unquote(:"get_#{singular}_by")(Keyword.t()) :: unquote(schema).t() | nil
      def unquote(:"get_#{singular}_by")(keywords),
        do: from(unquote(schema), where: ^keywords) |> Application.get_env(:ecto_interface, :default_repo).one()

      @doc """
      Returns a singular `#{unquote(schema)}` based on a query and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}")((Ecto.Query.t() -> Ecto.Query.t())) ::
              unquote(schema).t() | nil
      def unquote(:"get_#{singular}")(subquery) when is_function(subquery, 1),
        do: subquery.(unquote(schema)) |> Application.get_env(:ecto_interface, :default_repo).one()

      @doc """
      Returns a singular `#{unquote(schema)}` based on the primary key and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}")(String.t()) :: unquote(schema).t() | nil
      def unquote(:"get_#{singular}")(id) when is_binary(id),
        do: unquote(schema) |> Application.get_env(:ecto_interface, :default_repo).get(id)

      @doc """
      Returns a singular `#{unquote(schema)}` based on a query, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}!")((Ecto.Query.t() -> Ecto.Query.t())) ::
              unquote(schema).t()
      def unquote(:"get_#{singular}!")(subquery) when is_function(subquery, 1),
        do: subquery.(unquote(schema)) |> Application.get_env(:ecto_interface, :default_repo).one!()

      @doc """
      Returns a singular `#{unquote(schema)}` based on the primary key, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}!")(String.t()) :: unquote(schema).t()
      def unquote(:"get_#{singular}!")(id) when is_binary(id),
        do: unquote(schema) |> Application.get_env(:ecto_interface, :default_repo).get!(id)
    end
  end
end
