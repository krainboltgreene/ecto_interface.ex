defmodule EctoInterface.Write.Create do
  @moduledoc false
  defmacro __using__(options) when is_list(options) do
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

    quote(location: :keep) do
      @doc """
      Applies a `value` to a empty `#{unquote(source)}` via `#{unquote(source)}.changeset/2` and then inserts the changeset into the database. Allows for a list of
      preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}!")(any()) :: unquote(source).t()
      @spec unquote(:"create_#{singular}!")(any(), Keyword.t()) :: unquote(source).t()
      def unquote(:"create_#{singular}!")(value, options \\ []) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(source){}
        |> unquote(repo).preload(preload)
        |> (& apply(unquote(source), :changeset, [&1, value])).()
        |> unquote(repo).insert!(options)
        |> unquote(repo).preload(preload)
      end

      @doc """
      Applies a `value` to a empty `#{unquote(source)}` using `changeset` and then inserts resulting changeset into the database.
      Allows for a list of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}_by!")(any(), function()) ::
              unquote(source).t()
      @spec unquote(:"create_#{singular}_by!")(any(), function(), Keyword.t()) ::
              unquote(source).t()
      def unquote(:"create_#{singular}_by!")(value, changeset_function, options \\ [])
          when is_function(changeset_function) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(source){}
        |> unquote(repo).preload(preload)
        |> changeset_function.(value)
        |> unquote(repo).insert!(options)
        |> unquote(repo).preload(preload)
      end

      @doc """
      Applies a `value` to a empty `#{unquote(source)}` via `#{unquote(source)}.changeset/2` and then inserts the changeset into the database. Allows for a list of
      preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"create_#{singular}")(any()) ::
              {:ok, unquote(source).t()} | {:error, Ecto.Changeset.t(unquote(source).t())}
      @spec unquote(:"create_#{singular}")(any(), Keyword.t()) ::
              {:ok, unquote(source).t()} | {:error, Ecto.Changeset.t(unquote(source).t())}
      def unquote(:"create_#{singular}")(value, options \\ []) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(source){}
        |> unquote(repo).preload(preload)
        |> (& apply(unquote(source), :changeset, [&1, value])).()
        |> unquote(repo).insert(options)
        |> case do
          {:ok, record} ->
            {:ok, unquote(repo).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end

      @doc """
      Applies a `value` to a empty `#{unquote(source)}` using `changeset` and then inserts resulting changeset into the database.
      Allows for a list of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"create_#{singular}_by")(any(), function()) ::
              {:ok, unquote(source).t()} | {:error, Ecto.Changeset.t(unquote(source).t())}
      @spec unquote(:"create_#{singular}_by")(any(), function(), Keyword.t()) ::
              {:ok, unquote(source).t()} | {:error, Ecto.Changeset.t(unquote(source).t())}
      def unquote(:"create_#{singular}_by")(value, changeset_function, options \\ [])
          when is_function(changeset_function) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(source){}
        |> unquote(repo).preload(preload)
        |> changeset_function.(value)
        |> unquote(repo).insert(options)
        |> case do
          {:ok, record} ->
            {:ok, unquote(repo).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end
    end
  end
end
