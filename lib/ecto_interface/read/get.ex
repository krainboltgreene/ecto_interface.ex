defmodule EctoInterface.Read.Get do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural, singular])
           when is_atom(plural) and is_atom(singular) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns a singular `#{unquote(schema)}` based on a query and primary key, if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}_by")(
              String.t() | integer,
              (Ecto.Query.t() -> Ecto.Query.t())
            ) ::
              unquote(schema).t() | nil
      def unquote(:"get_#{singular}_by")(id, subquery, options \\ [])
          when (is_binary(id) or is_integer(id)) and is_function(subquery, 1),
          do:
            subquery.(unquote(schema))
            |> Application.get_env(:ecto_interface, :default_repo).get(id, options)

      @doc """
      Returns a singular `#{unquote(schema)}` based on the primary key and primary key, if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}")(String.t() | integer) :: unquote(schema).t() | nil
      def unquote(:"get_#{singular}")(id, options \\ []) when is_binary(id) or is_integer(id),
        do:
          unquote(schema) |> Application.get_env(:ecto_interface, :default_repo).get(id, options)

      @doc """
      Returns a singular `#{unquote(schema)}` based on a query, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}_by!")(
              String.t() | integer,
              (Ecto.Query.t() -> Ecto.Query.t())
            ) ::
              unquote(schema).t()
      def unquote(:"get_#{singular}_by!")(id, subquery, options \\ [])
          when is_binary(id) or (is_integer(id) and is_function(subquery, 1)),
          do:
            subquery.(unquote(schema))
            |> Application.get_env(:ecto_interface, :default_repo).get!(id, options)

      @doc """
      Returns a singular `#{unquote(schema)}` based on the primary key, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}!")(String.t() | integer) :: unquote(schema).t()
      def unquote(:"get_#{singular}!")(id, options \\ []) when is_binary(id) or is_integer(id),
        do:
          unquote(schema) |> Application.get_env(:ecto_interface, :default_repo).get!(id, options)
    end
  end
end
