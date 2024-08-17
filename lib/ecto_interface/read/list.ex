defmodule EctoInterface.Read.List do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural])
           when is_atom(plural) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns all `#{unquote(schema)}` records from a modified query
      """
      @spec unquote(:"list_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) ::
              list(unquote(schema))
      @spec unquote(:"list_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              list(unquote(schema))
      def unquote(:"list_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options),
          do:
            subquery.(from(unquote(schema)))
            |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).all(options)

      @doc """
      Returns all `#{unquote(schema)}` records, unsorted
      """
      @spec unquote(:"list_#{plural}")() :: list(unquote(schema).t())
      @spec unquote(:"list_#{plural}")(Keyword.t()) :: list(unquote(schema).t())
      def unquote(:"list_#{plural}")(options \\ []) when is_list(options),
        do:
          from(unquote(schema))
          |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).all(options)

      @doc """
      Returns a stream of `#{unquote(schema)}` records from a modified query
      """
      @spec unquote(:"stream_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) ::
              Enum.t()
      @spec unquote(:"stream_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              Enum.t()
      def unquote(:"stream_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options),
          do:
            subquery.(from(unquote(schema)))
            |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).stream(options)

      @doc """
      Returns a stream of `#{unquote(schema)}` records, unsorted
      """
      @spec unquote(:"stream_#{plural}")() :: Enum.t()
      @spec unquote(:"stream_#{plural}")(Keyword.t()) :: Enum.t()
      def unquote(:"stream_#{plural}")(options \\ []) when is_list(options),
        do:
          from(unquote(schema))
          |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).stream(options)

      @doc """
      Returns a stream of `#{unquote(schema)}` records from a modified query. There are two optional arguments: The first is the
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
            unquote(schema)
            |> from()
            |> subquery.()
            |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).paginate(
              pagination_options,
              repository_options
            )

      @doc """
      Returns a stream of `#{unquote(schema)}` records, unsorted. There are two optional arguments: The first is the
      `pagination_options` which govern the pagination mechanism. The second is the `repository_options` which governs
      the repository interface.
      """
      @spec unquote(:"paginate_#{plural}")() :: Enum.t()
      @spec unquote(:"paginate_#{plural}")(Keyword.t()) :: Enum.t()
      @spec unquote(:"paginate_#{plural}")(Keyword.t(), Keyword.t()) :: Enum.t()
      def unquote(:"paginate_#{plural}")(pagination_options \\ [], repository_options \\ [])
          when is_list(pagination_options) and is_list(repository_options),
          do:
            unquote(schema)
            |> from()
            |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).paginate(
              pagination_options,
              repository_options
            )
    end
  end
end
