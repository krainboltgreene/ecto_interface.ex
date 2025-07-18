defmodule EctoInterface.Write.Update do
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

    quote do
      @doc """
      Applies a `value` to the given `record`, a `#{__MODULE__.unquote(source)}`, via the `#{__MODULE__.unquote(source)}.changeset/2` function and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(__MODULE__.unquote(source).t(), any()) ::
              __MODULE__.unquote(source).t()
      def unquote(:"update_#{singular}!")(record, value, options \\ [])
          when is_struct(record, __MODULE__.unquote(source)) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> (&apply(__MODULE__.unquote(source), :changeset, [&1, value])).()
        |> unquote(repo).update!(options)
        |> unquote(repo).preload(preload)
      end

      @doc """
      Applies a `value` to the given `record`, a `#{__MODULE__.unquote(source)}`, with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}_by!")(
              __MODULE__.unquote(source).t(),
              any(),
              function()
            ) ::
              __MODULE__.unquote(source).t()
      def unquote(:"update_#{singular}_by!")(
            record,
            value,
            changeset_function,
            options \\ []
          )
          when is_struct(record, __MODULE__.unquote(source)) and
                 is_function(changeset_function, 2) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> changeset_function.(value)
        |> unquote(repo).update!(options)
        |> unquote(repo).preload(preload)
      end

      @doc """
      Applies a `value` to the given `record`, a `#{__MODULE__.unquote(source)}`, and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"update_#{singular}")(
              __MODULE__.unquote(source).t(),
              any(),
              Keyword.t(list())
            ) ::
              {:ok, __MODULE__.unquote(source).t()}
              | {:error, Ecto.Changeset.t(__MODULE__.unquote(source).t())}
      def unquote(:"update_#{singular}")(record, value, options \\ [])
          when is_struct(record, __MODULE__.unquote(source)) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> unquote(repo).preload(preload)
        |> (&apply(__MODULE__.unquote(source), :changeset, [&1, value])).()
        |> unquote(repo).update(options)
        |> case do
          {:ok, record} ->
            {:ok, unquote(repo).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end

      @doc """
      Applies a `value` to the given `record`, a `#{__MODULE__.unquote(source)}`, with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.
      """
      @spec unquote(:"update_#{singular}_by")(
              __MODULE__.unquote(source).t(),
              any(),
              function()
            ) ::
              {:ok, __MODULE__.unquote(source).t()}
              | {:error, Ecto.Changeset.t(__MODULE__.unquote(source).t())}
      def unquote(:"update_#{singular}_by")(record, value, changeset_function, options \\ [])
          when is_struct(record, __MODULE__.unquote(source)) and
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
