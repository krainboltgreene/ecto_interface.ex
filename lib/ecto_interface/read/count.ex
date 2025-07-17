defmodule EctoInterface.Read.Count do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__(options)
           when is_list(options) do
    source =
      Keyword.get(options, :source) ||
        raise "Missing :source key in use(EctoInterface) call"

    plural =
      Keyword.get(options, :plural) ||
        raise "Missing :plural key in use(EctoInterface) call"

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
      Counts the number of `#{__MODULE__.unquote(source)}` records in the databas e based on a set of conditions.
      """
      @spec unquote(:"count_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) :: integer()
      @spec unquote(:"count_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              integer()
      def unquote(:"count_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options) do
        unquote(repo).aggregate(
          subquery.(__MODULE__.unquote(source)),
          :count,
          :id,
          options
        )
      end

      @doc """
      Counts the number of `#{__MODULE__.unquote(source)}` records in the database.
      """
      @spec unquote(:"count_#{plural}")() :: integer()
      @spec unquote(:"count_#{plural}")(Keyword.t()) :: integer()
      def unquote(:"count_#{plural}")(options \\ []) when is_list(options) do
        unquote(repo).aggregate(
          __MODULE__.unquote(source),
          :count,
          :id,
          options
        )
      end
    end
  end
end
