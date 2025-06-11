defmodule EctoInterface.Paginator do
  @moduledoc """
  Defines a paginator.

  This module adds a `paginate/3` function to your `Ecto.Repo` so that you can
  paginate through results using opaque cursors.

  ## Usage

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app
        use EctoInterface.Paginator
      end

  ## Options

  `EctoInterface.Paginator` can take any options accepted by `paginate/3`. This is useful when
  you want to enforce some options globally across your project.

  ### Example

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app
        use EctoInterface.Paginator,
          limit: 10,                           # sets the default limit to 10
          maximum_limit: 100,                  # sets the maximum limit to 100
          include_total_count: true,           # include total count by default
          total_count_primary_key_field: :uuid # sets the total_count_primary_key_field to uuid for calculate total_count
      end

  Note that these values can be still be overridden when `paginate/3` is called.

  ### Use without macros

  If you wish to avoid use of macros or you wish to use a different name for
  the pagination function you can define your own function like so:

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app

        def my_paginate_function(queryable, opts \\ [], repo_opts \\ []) do
          defaults = [limit: 10] # Default options of your choice here
          opts = Keyword.merge(defaults, opts)
          EctoInterface.Paginator.paginate(queryable, opts, __MODULE__, repo_opts)
        end
      end
  """

  import Ecto.Query

  defmacro __using__(opts) do
    quote do
      @defaults unquote(opts)

      def paginate(queryable, opts \\ [], repo_opts \\ []) do
        opts = Keyword.merge(@defaults, opts)

        EctoInterface.Paginator.paginate(queryable, opts, __MODULE__, repo_opts)
      end
    end
  end

  @doc """
  Fetches all the results matching the query within the cursors.

  ## Options

    * `:after` - Fetch the records after this cursor.
    * `:before` - Fetch the records before this cursor.
    * `:cursor_fields` - The fields with sorting direction used to determine the
    cursor. In most cases, this should be the same fields as the ones used for sorting in the query.
    When you use named bindings in your query they can also be provided.
    * `:fetch_cursor_value_fun` function of arity 2 to lookup cursor values on returned records.
    Defaults to `EctoInterface.Paginator.default_fetch_cursor_value/2`
    * `:include_total_count` - Set this to true to return the total number of
    records matching the query, also returns extra page metadata. Note that
    this number will be capped by `:total_count_limit`. Defaults to `false`.
    * `:total_count_primary_key_field` - Running count queries on specified column of the table
    * `:limit` - Limits the number of records returned per page. Note that this
    number will be capped by `:maximum_limit`. Defaults to `50`.
    * `:maximum_limit` - Sets a maximum cap for `:limit`. This option can be useful when `:limit`
    is set dynamically (e.g from a URL param set by a user) but you still want to
    enfore a maximum. Defaults to `500`.
    * `:sort_direction` - The direction used for sorting. Defaults to `:asc`.
    It is preferred to set the sorting direction per field in `:cursor_fields`.
    * `:total_count_limit` - Running count queries on tables with a large number
    of records is expensive so it is capped by default. Can be set to `:infinity`
    in order to count all the records. Defaults to `10,000`.

  ## Repo options

  This will be passed directly to `Ecto.Repo.all/2`, as such any option supported
  by this function can be used here.

  ## Simple example

      query = from(p in Post, order_by: [asc: p.inserted_at, asc: p.id], select: p)

      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 50)

  ## Example with using custom sort directions per field

      query = from(p in Post, order_by: [asc: p.inserted_at, desc: p.id], select: p)

      Repo.paginate(query, cursor_fields: [inserted_at: :asc, id: :desc], limit: 50)

  ## Example with sorting on columns in joined tables

      from(
        p in Post,
        as: :posts,
        join: a in assoc(p, :author),
        as: :author,
        preload: [author: a],
        select: p,
        order_by: [
          {:asc, a.name},
          {:asc, p.id}
        ]
      )

      Repo.paginate(query, cursor_fields: [{{:author, :name}, :asc}, id: :asc], limit: 50)

  When sorting on columns in joined tables it is necessary to use named bindings. In
  this case we name it `author`. In the `cursor_fields` we refer to this named binding
  and its column name.

  To build the cursor EctoInterface.Paginator uses the returned Ecto.Schema. When using a joined
  column the returned Ecto.Schema won't have the value of the joined column
  unless we preload it. E.g. in this case the cursor will be build up from
  `post.id` and `post.author.name`. This presupposes that the named of the
  binding is the same as the name of the relationship on the original struct.

  One level deep joins are supported out of the box but if we join on a second
  level, e.g. `post.author.company.name` a custom function can be supplied to
  handle the cursor value retrieval. This also applies when the named binding
  does not map to the name of the relationship.

  ## Example
      from(
        p in Post,
        as: :posts,
        join: a in assoc(p, :author),
        as: :author,
        join: c in assoc(a, :company),
        as: :company,
        preload: [author: a],
        select: p,
        order_by: [
          {:asc, a.name},
          {:asc, p.id}
        ]
      )

      Repo.paginate(query,
        cursor_fields: [{{:company, :name}, :asc}, id: :asc],
        fetch_cursor_value_fun: fn
          post, {:company, name} ->
            post.author.company.name

          post, field ->
            EctoInterface.Paginator.default_fetch_cursor_value(post, field)
        end,
        limit: 50
      )

  """
  @callback paginate(queryable :: Ecto.Query.t(), opts :: Keyword.t(), repo_opts :: Keyword.t()) ::
              EctoInterface.Paginator.Page.t()

  @doc false
  def paginate(queryable, opts, repo, repo_opts) do
    config = EctoInterface.Paginator.Config.new(opts)

    EctoInterface.Paginator.Config.validate!(config)

    sorted_entries = entries(queryable, config, repo, repo_opts)
    paginated_entries = paginate_entries(sorted_entries, config)
    extra_page_metadata = fetch_extra_page_metadata(queryable, config, repo, repo_opts)

    %EctoInterface.Paginator.Page{
      entries: paginated_entries,
      metadata:
        struct(
          %EctoInterface.Paginator.PageMetadata{
            before: before_cursor(paginated_entries, sorted_entries, config),
            after: after_cursor(paginated_entries, sorted_entries, config),
            limit: config.limit
          },
          extra_page_metadata
        )
    }
  end

  @doc """
  Generate a cursor for the supplied record, in the same manner as the
  `before` and `after` cursors generated by `paginate/3`.

  For the cursor to be compatible with `paginate/3`, `cursor_fields`
  must have the same value as the `cursor_fields` option passed to it.

  ### Example

      iex> EctoInterface.Paginator.cursor_for_record(%Customer{id: 1}, [:id])
      "g3QAAAABZAACaWRhAQ=="

      iex> EctoInterface.Paginator.cursor_for_record(%Customer{id: 1, name: "Alice"}, [id: :asc, name: :desc])
      "g3QAAAACZAACaWRhAWQABG5hbWVtAAAABUFsaWNl"
  """
  @spec cursor_for_record(
          any(),
          [atom() | {atom(), atom()}],
          (map(), atom() | {atom(), atom()} -> any())
        ) :: binary()
  def cursor_for_record(
        record,
        cursor_fields,
        fetch_cursor_value_fun \\ &EctoInterface.Paginator.default_fetch_cursor_value/2
      ) do
    fetch_cursor_value(record, %EctoInterface.Paginator.Config{
      cursor_fields: cursor_fields,
      fetch_cursor_value_fun: fetch_cursor_value_fun
    })
  end

  @doc """
  Default function used to get the value of a cursor field from the supplied
  map. This function can be overridden in the `EctoInterface.Paginator.Config` using the
  `fetch_cursor_value_fun` key.

  When using named bindings to sort on joined columns it will attempt to get
  the value of joined column by using the named binding as the name of the
  relationship on the original Ecto.Schema.

  ### Example

      iex> EctoInterface.Paginator.default_fetch_cursor_value(%Customer{id: 1}, :id)
      1

      iex> EctoInterface.Paginator.default_fetch_cursor_value(%Customer{id: 1, address: %Address{city: "London"}}, {:address, :city})
      "London"
  """

  @spec default_fetch_cursor_value(map(), atom() | {atom(), atom()}) :: any()
  def default_fetch_cursor_value(schema, {binding, field})
      when is_atom(binding) and is_atom(field) do
    case Map.get(schema, field) do
      nil -> Map.get(schema, binding) |> Map.get(field)
      value -> value
    end
  end

  def default_fetch_cursor_value(schema, field) when is_atom(field) do
    Map.get(schema, field)
  end

  defp before_cursor([], [], _config), do: nil

  defp before_cursor(_paginated_entries, _sorted_entries, %EctoInterface.Paginator.Config{
         after: nil,
         before: nil
       }),
       do: nil

  defp before_cursor(
         paginated_entries,
         _sorted_entries,
         %EctoInterface.Paginator.Config{after: c_after} = config
       )
       when not is_nil(c_after) do
    first_or_nil(paginated_entries, config)
  end

  defp before_cursor(paginated_entries, sorted_entries, config) do
    if first_page?(sorted_entries, config) do
      nil
    else
      first_or_nil(paginated_entries, config)
    end
  end

  defp first_or_nil(entries, config) do
    if first = List.first(entries) do
      fetch_cursor_value(first, config)
    else
      nil
    end
  end

  defp after_cursor([], [], _config), do: nil

  defp after_cursor(
         paginated_entries,
         _sorted_entries,
         %EctoInterface.Paginator.Config{before: c_before} = config
       )
       when not is_nil(c_before) do
    last_or_nil(paginated_entries, config)
  end

  defp after_cursor(paginated_entries, sorted_entries, config) do
    if last_page?(sorted_entries, config) do
      nil
    else
      last_or_nil(paginated_entries, config)
    end
  end

  defp last_or_nil(entries, config) do
    if last = List.last(entries) do
      fetch_cursor_value(last, config)
    else
      nil
    end
  end

  defp fetch_cursor_value(nil, _config), do: nil

  defp fetch_cursor_value(schema, %EctoInterface.Paginator.Config{
         cursor_fields: cursor_fields,
         fetch_cursor_value_fun: fetch_cursor_value_fun
       }) do
    cursor_fields
    |> Enum.map(fn
      {{cursor_field, func}, _order} when is_atom(cursor_field) and is_function(func) ->
        {cursor_field, fetch_cursor_value_fun.(schema, cursor_field)}

      {cursor_field, func} when is_atom(cursor_field) and is_function(func) ->
        {cursor_field, fetch_cursor_value_fun.(schema, cursor_field)}

      {cursor_field, _order} ->
        {cursor_field, fetch_cursor_value_fun.(schema, cursor_field)}

      cursor_field when is_atom(cursor_field) ->
        {cursor_field, fetch_cursor_value_fun.(schema, cursor_field)}
    end)
    |> Map.new()
    |> EctoInterface.Paginator.Cursor.encode()
  end

  defp first_page?(sorted_entries, %EctoInterface.Paginator.Config{limit: limit}) do
    Enum.count(sorted_entries) <= limit
  end

  defp last_page?(sorted_entries, %EctoInterface.Paginator.Config{limit: limit}) do
    Enum.count(sorted_entries) <= limit
  end

  defp entries(queryable, config, repo, repo_opts) do
    queryable
    |> EctoInterface.Paginator.Ecto.Query.paginate(config)
    |> repo.all(repo_opts)
  end

  defp fetch_cursor_fields_list(%EctoInterface.Paginator.Config{
         cursor_fields: cursor_fields,
         sort_direction: sort_direction
       }) do
    cursor_fields
    |> Enum.map(fn
      {{cursor_field, _func}, order} when is_atom(cursor_field) ->
        {cursor_field, order}

      cursor_field when is_atom(cursor_field) ->
        {cursor_field, sort_direction}

      {cursor_field, order} ->
        {cursor_field, order}
    end)
  end

  defp reverse_dir(dir) do
    case dir do
      :desc -> :asc
      :desc_nulls_last -> :asc_nulls_first
      :desc_nulls_first -> :asc_nulls_last
      :asc -> :desc
      :asc_nulls_last -> :desc_nulls_first
      :asc_nulls_first -> :desc_nulls_last
    end
  end

  defp json_build_object(%EctoInterface.Paginator.Config{} = config) do
    fetch_cursor_fields_list(config)
    |> Enum.map(&elem(&1, 0))
    |> json_build_object()
  end

  defp json_build_object(fields) when is_list(fields) do
    last_index = length(fields) - 1

    body =
      Enum.with_index(fields)
      |> Enum.reduce(dynamic(fragment("json_build_object(")), fn {field_name, index},
                                                                 %Ecto.Query.DynamicExpr{} =
                                                                   query ->
        if last_index == index do
          dynamic(
            [q],
            fragment(
              "??, ?",
              ^query,
              type(^to_string(field_name), :string),
              field(q, ^field_name)
            )
          )
        else
          dynamic(
            [q],
            fragment(
              "??, ?,",
              ^query,
              type(^to_string(field_name), :string),
              field(q, ^field_name)
            )
          )
        end
      end)

    dynamic([q], fragment("?)", ^body))
  end

  defp reverse_cursor_sort(cursor_fields_list),
    do:
      Enum.map(cursor_fields_list, fn {cursor_field, dir} -> {reverse_dir(dir), cursor_field} end)

  defmacro mod(dividend, divisor) do
    quote do
      fragment("MOD(?, ?)", unquote(dividend), unquote(divisor))
    end
  end

  defmacro case_when(condition, then_expr, else_expr) do
    quote do
      fragment(
        "CASE WHEN ? THEN ? ELSE ? END",
        unquote(condition),
        unquote(then_expr),
        unquote(else_expr)
      )
    end
  end

  defp last_cursor_query(%EctoInterface.Paginator.Config{limit: limit} = config) do
    cursor_fields_sort = fetch_cursor_fields_list(config)

    from(q in "queryable",
      select: ^json_build_object(config),
      offset:
        case_when(
          fragment("? = 0", mod(parent_as(:total_count).overlimit, ^limit)),
          ^limit,
          mod(parent_as(:total_count).overlimit, ^limit)
        ) + parent_as(:total_count).exceeded,
      limit: 1,
      order_by: ^reverse_cursor_sort(cursor_fields_sort)
    )
  end

  defp total_count_query(%EctoInterface.Paginator.Config{
         total_count_limit: :infinity,
         total_count_primary_key_field: total_count_primary_key_field
       }) do
    from(q in "queryable",
      select: %{
        total: count(field(q, ^total_count_primary_key_field)),
        exceeded: 0,
        overlimit: count(field(q, ^total_count_primary_key_field))
      }
    )
  end

  defp total_count_query(%EctoInterface.Paginator.Config{
         total_count_limit: total_count_limit,
         total_count_primary_key_field: total_count_primary_key_field
       }) do
    from(q in "queryable",
      select: %{
        total: count(field(q, ^total_count_primary_key_field)),
        exceeded:
          fragment(
            "(?)::int",
            count(field(q, ^total_count_primary_key_field)) > ^total_count_limit
          ),
        overlimit:
          fragment(
            "? - (?)::int",
            count(field(q, ^total_count_primary_key_field)),
            count(field(q, ^total_count_primary_key_field)) > ^total_count_limit
          )
      }
    )
  end

  defp query_extra_page_metadata(
         queryable,
         %EctoInterface.Paginator.Config{
           limit: limit,
           total_count_limit: total_count_limit
         } = config,
         repo,
         repo_opts
       )
       when is_struct(queryable, Ecto.Query) do
    queryable =
      queryable
      |> exclude(:order_by)
      |> exclude(:preload)

    %{total: total_count, last_page_record: last_page_record} =
      from(r in "total_count", as: :total_count)
      |> with_cte("queryable", as: ^queryable)
      |> with_cte("total_count", as: ^total_count_query(config))
      |> select([r], %{
        total: r.total,
        exceeded_total_limit: r.exceeded,
        last_page_record: subquery(last_cursor_query(config))
      })
      |> repo.one(repo_opts)

    capped_total_count = Enum.min([total_count, total_count_limit])

    total_pages =
      div(capped_total_count, limit) + if(rem(capped_total_count, limit) > 0, do: 1, else: 0)

    cursor_fields_sort = fetch_cursor_fields_list(config)

    last_page_record =
      load_from_schema(queryable, last_page_record, Enum.map(cursor_fields_sort, &elem(&1, 0)))

    %{
      last_page_after: fetch_cursor_value(last_page_record, config),
      total_pages: total_pages,
      total_count: capped_total_count,
      total_count_cap_exceeded: total_count > total_count_limit
    }
  end

  defp load_from_schema(_queryable, nil, _fields), do: nil

  # NOTE: repo.load(schema, record) does not cast correctly for some reason
  defp load_from_schema(queryable, record, fields) do
    %{from: %{source: {_table, schema}}} = queryable

    struct = schema.__schema__(:loaded) |> Map.take(fields)

    schema.__schema__(:load)
    |> Map.new()
    |> Map.take(fields)
    |> Enum.reduce(struct, fn {field, type}, acc ->
      Map.put(acc, field, Ecto.Type.cast!(type, Map.get(record, Atom.to_string(field))))
    end)
  end

  defp fetch_extra_page_metadata(
         _queryable,
         %EctoInterface.Paginator.Config{include_total_count: false},
         _repo,
         _repo_opts
       ),
       do: %{}

  defp fetch_extra_page_metadata(
         queryable,
         %EctoInterface.Paginator.Config{total_count_limit: :infinity} = config,
         repo,
         repo_opts
       ) do
    queryable
    |> query_extra_page_metadata(config, repo, repo_opts)
  end

  defp fetch_extra_page_metadata(
         queryable,
         %EctoInterface.Paginator.Config{total_count_limit: total_count_limit} = config,
         repo,
         repo_opts
       ) do
    queryable
    |> limit(^(total_count_limit + 1))
    |> query_extra_page_metadata(config, repo, repo_opts)
  end

  # `sorted_entries` returns (limit+1) records, so before
  # returning the page, we want to take only the first (limit).
  #
  # When we have only a before cursor, we get our results from
  # sorted_entries in reverse order due t
  defp paginate_entries(sorted_entries, %EctoInterface.Paginator.Config{
         before: before,
         after: nil,
         limit: limit
       })
       when not is_nil(before) do
    sorted_entries
    |> Enum.take(limit)
    |> Enum.reverse()
  end

  defp paginate_entries(sorted_entries, %EctoInterface.Paginator.Config{limit: limit}),
    do: Enum.take(sorted_entries, limit)
end
