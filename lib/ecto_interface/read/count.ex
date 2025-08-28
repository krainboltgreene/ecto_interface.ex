defmodule EctoInterface.Read.Count do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__(options)
           when is_list(options) do
    source =
      EctoInterface.expand_alias(
        Keyword.get(options, :source) ||
          raise("Missing :source key in use(EctoInterface) call"),
        __CALLER__
      )

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
      Returns a multi that will count `#{unquote(source)}` records based on `subquery`.
      """
      @spec unquote(:"count_#{plural}_multi_by")(Ecto.Multi.t(), atom(), (Ecto.Query.t() ->
                                                                            Ecto.Query.t())) ::
              Ecto.Multi.t()
      def unquote(:"count_#{plural}_multi_by")(multi, slug, subquery)
          when is_struct(multi, Ecto.Multi) and is_atom(slug) and is_function(subquery, 1) do
        Ecto.Multi.one(
          multi,
          slug,
          subquery.(from(row in unquote(source), select: count(row.id)))
        )
      end

      @doc """
      Returns a multi that will count `#{unquote(source)}` records, unsorted
      """
      @spec unquote(:"count_#{plural}_multi")(Ecto.Multi.t(), atom()) :: Ecto.Multi.t()
      def unquote(:"count_#{plural}_multi")(multi, slug)
          when is_struct(multi, Ecto.Multi) and is_atom(slug) do
        Ecto.Multi.one(multi, slug, from(row in unquote(source), select: count(row.id)))
      end

      @doc """
      Counts the number of `#{unquote(source)}` records in the database based on `subquery`.
      """
      @spec unquote(:"count_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) :: integer()
      @spec unquote(:"count_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              integer()
      def unquote(:"count_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options) do
        unquote(repo).aggregate(
          subquery.(unquote(source)),
          :count,
          :id,
          options
        )
      end

      @doc """
      Counts the number of `#{unquote(source)}` records in the database.
      """
      @spec unquote(:"count_#{plural}")() :: integer()
      @spec unquote(:"count_#{plural}")(Keyword.t()) :: integer()
      def unquote(:"count_#{plural}")(options \\ []) when is_list(options) do
        unquote(repo).aggregate(
          unquote(source),
          :count,
          :id,
          options
        )
      end
    end
  end
end
