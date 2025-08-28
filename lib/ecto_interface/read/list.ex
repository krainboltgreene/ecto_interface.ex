defmodule EctoInterface.Read.List do
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
      Returns a multi that will return `#{unquote(source)}` records, modified by `subquery`.
      """
      @spec unquote(:"list_#{plural}_multi_by")(Ecto.Multi.t(), atom(), (Ecto.Query.t() ->
                                                                           Ecto.Query.t())) ::
              Ecto.Multi.t()
      def unquote(:"list_#{plural}_multi_by")(multi, slug, subquery)
          when is_struct(multi, Ecto.Multi) and is_atom(slug) and is_function(subquery, 1) do
        Ecto.Multi.all(multi, slug, subquery.(from(unquote(source))))
      end

      @doc """
      Returns a multi that will return `#{unquote(source)}` records, unsorted
      """
      @spec unquote(:"list_#{plural}_multi")(Ecto.Multi.t(), atom()) :: Ecto.Multi.t()
      def unquote(:"list_#{plural}_multi")(multi, slug)
          when is_struct(multi, Ecto.Multi) and is_atom(slug) do
        Ecto.Multi.all(multi, slug, from(unquote(source)))
      end

      @doc """
      Returns all `#{unquote(source)}` records from a modified query
      """
      @spec unquote(:"list_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) ::
              list(unquote(source))
      @spec unquote(:"list_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              list(unquote(source))
      def unquote(:"list_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options),
          do:
            subquery.(from(unquote(source)))
            |> unquote(repo).all(options)

      @doc """
      Returns all `#{unquote(source)}` records, unsorted
      """
      @spec unquote(:"list_#{plural}")() :: list(unquote(source).t())
      @spec unquote(:"list_#{plural}")(Keyword.t()) :: list(unquote(source).t())
      def unquote(:"list_#{plural}")(options \\ []) when is_list(options),
        do:
          from(unquote(source))
          |> unquote(repo).all(options)

      @doc """
      Returns a stream of `#{unquote(source)}` records from a modified query
      """
      @spec unquote(:"stream_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) ::
              Enum.t()
      @spec unquote(:"stream_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              Enum.t()
      def unquote(:"stream_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options),
          do:
            subquery.(from(unquote(source)))
            |> unquote(repo).stream(options)

      @doc """
      Returns a stream of `#{unquote(source)}` records, unsorted
      """
      @spec unquote(:"stream_#{plural}")() :: Enum.t()
      @spec unquote(:"stream_#{plural}")(Keyword.t()) :: Enum.t()
      def unquote(:"stream_#{plural}")(options \\ []) when is_list(options),
        do:
          from(unquote(source))
          |> unquote(repo).stream(options)

      @doc """
      Returns a stream of `#{unquote(source)}` records from a modified query. There are two optional arguments: The first is the
      `pagination_options` which govern the pagination mechanism. The second is the `repository_options` which governs
      the repository interface.
      """
      @spec unquote(:"paginate_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) ::
              Enum.t()
      @spec unquote(:"paginate_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              Enum.t()
      @spec unquote(:"paginate_#{plural}_by")(
              (Ecto.Query.t() -> Ecto.Query.t()),
              Keyword.t(),
              Keyword.t()
            ) ::
              Enum.t()
      def unquote(:"paginate_#{plural}_by")(
            subquery,
            pagination_options \\ [],
            repository_options \\ []
          )
          when is_function(subquery, 1) and is_list(pagination_options) and
                 is_list(repository_options),
          do:
            unquote(source)
            |> from()
            |> subquery.()
            |> unquote(repo).paginate(
              pagination_options,
              repository_options
            )

      @doc """
      Returns a stream of `#{unquote(source)}` records, unsorted. There are two optional arguments: The first is the
      `pagination_options` which govern the pagination mechanism. The second is the `repository_options` which governs
      the repository interface.
      """
      @spec unquote(:"paginate_#{plural}")() :: Enum.t()
      @spec unquote(:"paginate_#{plural}")(Keyword.t()) :: Enum.t()
      @spec unquote(:"paginate_#{plural}")(Keyword.t(), Keyword.t()) :: Enum.t()
      def unquote(:"paginate_#{plural}")(pagination_options \\ [], repository_options \\ [])
          when is_list(pagination_options) and is_list(repository_options),
          do:
            unquote(source)
            |> from()
            |> unquote(repo).paginate(
              pagination_options,
              repository_options
            )
    end
  end
end
