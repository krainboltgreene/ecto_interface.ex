defmodule EctoInterface do
  @moduledoc """
  EctoInterface is a suite of commonly defined APIs for Ecto-based models. Almost all of these came from the normal
  generated content in a new phoenix project, simply unifying and expanding on that suite.
  """

  @doc """
  Using this expression in your context module:

      use(EctoInterface, source: Core.Commerce.Product, plural: :products, singular: :product])

  Will automatically define a whole suite of functions for that schema.
  """
  defmacro __using__(options) do
    source =
      EctoInterface.expand_alias(
        Keyword.get(options, :source) ||
          raise("Missing :source key in use(EctoInterface) call"),
        __CALLER__
      )

    plural =
      Keyword.get(options, :plural) ||
        raise "Missing :plural key in use(EctoInterface) call"

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

    pubsub =
      Keyword.get(
        options,
        :pubsub,
        Application.get_env(:ecto_interface, :default_pubsub, false)
      )

    slug = Keyword.get(options, :slug, false)
    tagged = Keyword.get(options, :tagged, false)

    [
      quote do
        @doc """
        Returns a multi that will count `#{unquote(source)}` records, unsorted
        """
        @spec unquote(:"count_#{plural}_multi")(Ecto.Multi.t(), atom()) :: Ecto.Multi.t()
        def unquote(:"count_#{plural}_multi")(multi, slug)
            when is_struct(multi, Ecto.Multi) and is_atom(slug) do
          Ecto.Multi.one(multi, slug, from(row in unquote(source), select: count(row.id)))
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

        @doc """
        Returns a multi that will return a `#{unquote(source)}` record, unsorted
        """
        @spec unquote(:"get_#{singular}_multi")(Ecto.Multi.t(), atom(), String.t() | integer) ::
                Ecto.Multi.t()
        def unquote(:"get_#{singular}_multi")(multi, slug, id)
            when is_struct(multi, Ecto.Multi) and is_atom(slug) and
                   (is_binary(id) or is_integer(id)) do
          Ecto.Multi.one(
            multi,
            slug,
            from(row in unquote(source), where: row.id == ^id, limit: 1)
          )
        end

        @doc """
        Returns a singular `#{unquote(source)}` based on the primary key and primary key, if no record is found it returns `nil`
        """
        @spec unquote(:"get_#{singular}")(String.t() | integer) ::
                unquote(source).t() | nil
        @spec unquote(:"get_#{singular}")(String.t() | integer, Keyword.t()) ::
                unquote(source).t() | nil
        def unquote(:"get_#{singular}")(id, options \\ []) when is_binary(id) or is_integer(id),
          do:
            unquote(source)
            |> unquote(repo).get(id, options)

        @doc """
        Returns a singular `#{unquote(source)}` based on the primary key, but if it isn't found will raise an exception
        """
        @spec unquote(:"get_#{singular}!")(String.t() | integer) :: unquote(source).t()
        @spec unquote(:"get_#{singular}!")(String.t() | integer, Keyword.t()) ::
                unquote(source).t()
        def unquote(:"get_#{singular}!")(id, options \\ []) when is_binary(id) or is_integer(id),
          do:
            unquote(source)
            |> unquote(repo).get!(id, options)

        @doc """
        Returns a multi that will return `#{unquote(source)}` records, unsorted
        """
        @spec unquote(:"list_#{plural}_multi")(Ecto.Multi.t(), atom()) :: Ecto.Multi.t()
        def unquote(:"list_#{plural}_multi")(multi, slug)
            when is_struct(multi, Ecto.Multi) and is_atom(slug) do
          Ecto.Multi.all(multi, slug, from(unquote(source)))
        end

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
        Returns a stream of `#{unquote(source)}` records, unsorted
        """
        @spec unquote(:"stream_#{plural}")() :: Enum.t()
        @spec unquote(:"stream_#{plural}")(Keyword.t()) :: Enum.t()
        def unquote(:"stream_#{plural}")(options \\ []) when is_list(options),
          do:
            from(unquote(source))
            |> unquote(repo).stream(options)

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

        @doc """
        Randomly selects a `#{unquote(source)}` record
        """
        @spec unquote(:"random_#{singular}")() :: unquote(source).t() | nil
        @spec unquote(:"random_#{singular}")(Keyword.t()) :: unquote(source).t() | nil
        def unquote(:"random_#{singular}")(options \\ []) do
          from(unquote(source), limit: 1, order_by: fragment("random()"))
          |> unquote(repo).one(options)
        end

        @doc """
        Randomly selects `count` `#{unquote(source)}` records.
        """
        @spec unquote(:"random_#{plural}")(integer()) :: list(unquote(source).t())
        @spec unquote(:"random_#{plural}")(integer(), Keyword.t()) ::
                list(unquote(source).t())
        def unquote(:"random_#{plural}")(count, options \\ []) when is_integer(count) do
          from(unquote(source), limit: ^count, order_by: fragment("random()"))
          |> unquote(repo).all(options)
        end

        @doc """
        Takes an `#{unquote(source)}` and deletes it from the database.
        """
        @spec unquote(:"delete_#{singular}")(unquote(source).t()) ::
                {:ok, unquote(source).t()}
                | {:error, Ecto.Changeset.t(unquote(source).t())}
        def unquote(:"delete_#{singular}")(record, options \\ [])
            when is_struct(record, unquote(source)),
            do: unquote(repo).delete(record, options)

        @doc """
        Takes an `#{unquote(source)}` and deletes it from the database.

        If the row can't be found or constraints prevent you from deleting the row, this will raise an exception.
        """
        @spec unquote(:"delete_#{singular}!")(unquote(source).t()) ::
                unquote(source).t()
        def unquote(:"delete_#{singular}!")(record, options \\ [])
            when is_struct(record, unquote(source)),
            do: unquote(repo).delete!(record, options)
      end,
      if pubsub do
        quote do
          use EctoInterface.PubSub,
            plural: unquote(plural),
            singular: unquote(singular),
            pubsub: unquote(pubsub)
        end
      end,
      if tagged do
        quote do
          @doc """
          Returns a singular `#{unquote(source)}` based on the slug column, but if it isn't found will raise an exception
          """
          @spec unquote(:"get_#{singular}_by_slug!")(String.t()) :: unquote(source).t()
          @spec unquote(:"get_#{singular}_by_slug!")(String.t(), Keyword.t()) ::
                  unquote(source).t()
          def unquote(:"get_#{singular}_by_slug!")(name_or_slug, options \\ [])
              when is_binary(name_or_slug),
              do:
                unquote(source)
                |> from(where: [{unquote(slug), ^Slugy.slugify(name_or_slug)}], limit: 1)
                |> unquote(repo).one!(options)

          @doc """
          Returns a singular `#{unquote(source)}` based on the slug column and if no record is found it returns `nil`
          """
          @spec unquote(:"get_#{singular}_by_slug")(String.t()) ::
                  unquote(source).t() | nil
          @spec unquote(:"get_#{singular}_by_slug")(String.t(), Keyword.t()) ::
                  unquote(source).t() | nil
          def unquote(:"get_#{singular}_by_slug")(name_or_slug, options \\ [])
              when is_binary(name_or_slug),
              do:
                unquote(source)
                |> from(where: [{unquote(slug), ^Slugy.slugify(name_or_slug)}], limit: 1)
                |> unquote(repo).one(options)
        end
      end,
      if slug do
        quote do
          @doc """
          Returns all `#{unquote(source)}` records that have *all* of the given tags
          """
          @spec unquote(:"list_#{plural}_with_tags")(list(String.t())) ::
                  list(unquote(source).t())
          @spec unquote(:"list_#{plural}_with_tags")(list(String.t()), Keyword.t()) ::
                  list(unquote(source).t())
          def unquote(:"list_#{plural}_with_tags")(tags, options \\ [])

          def unquote(:"list_#{plural}_with_tags")([], options),
            do: []

          def unquote(:"list_#{plural}_with_tags")(tags, options) when is_list(tags) do
            from(
              record in unquote(source),
              join: tag in assoc(record, unquote(tagged)),
              having: fragment("? @> ?", fragment("array_agg(?)", tag.slug), ^tags),
              group_by: record.id
            )
            |> unquote(repo).all(options)
          end
        end
      end
    ]
  end

  def expand_alias({:__aliases__, _, _} = alias, env) when is_struct(env, Macro.Env) do
    Module.concat(env.module, Macro.expand(alias, %{env | function: {:init, 1}}))
  end
end
