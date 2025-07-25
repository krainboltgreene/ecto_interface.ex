defmodule EctoInterface.Read.Get do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__(options)
           when is_list(options) do
    source =
      Keyword.get(options, :source) ||
        raise "Missing :source key in use(EctoInterface) call"

    singular =
      Keyword.get(options, :singular) ||
        raise "Missing :singular key in use(EctoInterface) call"

    repo =
      Keyword.get(
        options,
        :repo,
        Application.get_env(:ecto_interface, :default_repo)
      ) ||
        raise "Missing :repo key in use(EctoInterface) call OR missing :default_repo in configuration"

    quote do
      import Ecto.Query

      @doc """
      Returns a singular `#{__MODULE__.unquote(source)}` based on a query and primary key, if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}_by")(
              String.t() | integer,
              (Ecto.Query.t() -> Ecto.Query.t())
            ) ::
              __MODULE__.unquote(source).t() | nil
      @spec unquote(:"get_#{singular}_by")(
              String.t() | integer,
              (Ecto.Query.t() -> Ecto.Query.t()),
              Keyword.t()
            ) ::
              __MODULE__.unquote(source).t() | nil
      def unquote(:"get_#{singular}_by")(id, subquery, options \\ [])
          when (is_binary(id) or is_integer(id)) and is_function(subquery, 1),
          do:
            subquery.(__MODULE__.unquote(source))
            |> unquote(repo).get(id, options)

      @doc """
      Returns a singular `#{__MODULE__.unquote(source)}` based on the primary key and primary key, if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}")(String.t() | integer) ::
              __MODULE__.unquote(source).t() | nil
      @spec unquote(:"get_#{singular}")(String.t() | integer, Keyword.t()) ::
              __MODULE__.unquote(source).t() | nil
      def unquote(:"get_#{singular}")(id, options \\ []) when is_binary(id) or is_integer(id),
        do:
          __MODULE__.unquote(source)
          |> unquote(repo).get(id, options)

      @doc """
      Returns a singular `#{__MODULE__.unquote(source)}` based on a query, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}_by!")(
              String.t() | integer,
              (Ecto.Query.t() -> Ecto.Query.t())
            ) ::
              __MODULE__.unquote(source).t()
      @spec unquote(:"get_#{singular}_by!")(
              String.t() | integer,
              (Ecto.Query.t() -> Ecto.Query.t()),
              Keyword.t()
            ) ::
              __MODULE__.unquote(source).t()
      def unquote(:"get_#{singular}_by!")(id, subquery, options \\ [])
          when is_binary(id) or (is_integer(id) and is_function(subquery, 1)),
          do:
            subquery.(__MODULE__.unquote(source))
            |> unquote(repo).get!(id, options)

      @doc """
      Returns a singular `#{__MODULE__.unquote(source)}` based on the primary key, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}!")(String.t() | integer) :: __MODULE__.unquote(source).t()
      @spec unquote(:"get_#{singular}!")(String.t() | integer, Keyword.t()) ::
              __MODULE__.unquote(source).t()
      def unquote(:"get_#{singular}!")(id, options \\ []) when is_binary(id) or is_integer(id),
        do:
          __MODULE__.unquote(source)
          |> unquote(repo).get!(id, options)
    end
  end
end
