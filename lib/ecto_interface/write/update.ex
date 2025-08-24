defmodule EctoInterface.Write.Update do
  @moduledoc false
  defmacro __using__(options) when is_list(options) do
    source =
      EctoInterface.expand_alias(
        Keyword.get(options, :source) ||
          raise("Missing :source key in use(EctoInterface) call"),
        __CALLER__
      )

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
      @doc """
      Applies a `value` to the given `record`, a `#{unquote(source)}`, via the `#{unquote(source)}.changeset/2` function and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(unquote(source).t(), any()) ::
              unquote(source).t()
      def unquote(:"update_#{singular}!")(record, value, options \\ [])
          when is_struct(record, unquote(source)) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> (&apply(unquote(source), :changeset, [&1, value])).()
        |> unquote(repo).update!(options)
        |> unquote(repo).preload(preload)
      end

      @doc """
      Applies a `value` to the given `record`, a `#{unquote(source)}`, with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}_by!")(
              unquote(source).t(),
              any(),
              function()
            ) ::
              unquote(source).t()
      def unquote(:"update_#{singular}_by!")(
            record,
            value,
            changeset_function,
            options \\ []
          )
          when is_struct(record, unquote(source)) and
                 is_function(changeset_function, 2) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> changeset_function.(value)
        |> unquote(repo).update!(options)
        |> unquote(repo).preload(preload)
      end

      @doc """
      Applies a `value` to the given `record`, a `#{unquote(source)}`, and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"update_#{singular}")(
              unquote(source).t(),
              any(),
              Keyword.t(list())
            ) ::
              {:ok, unquote(source).t()}
              | {:error, Ecto.Changeset.t(unquote(source).t())}
      def unquote(:"update_#{singular}")(record, value, options \\ [])
          when is_struct(record, unquote(source)) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> (&apply(unquote(source), :changeset, [&1, value])).()
        |> unquote(repo).update(options)
        |> case do
          {:ok, record} ->
            {:ok, unquote(repo).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end

      @doc """
      Applies a `value` to the given `record`, a `#{unquote(source)}`, with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.
      """
      @spec unquote(:"update_#{singular}_by")(
              unquote(source).t(),
              any(),
              function()
            ) ::
              {:ok, unquote(source).t()}
              | {:error, Ecto.Changeset.t(unquote(source).t())}
      def unquote(:"update_#{singular}_by")(record, value, changeset_function, options \\ [])
          when is_struct(record, unquote(source)) and
                 is_function(changeset_function, 2) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> changeset_function.(value)
        |> unquote(repo).update(options)
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
