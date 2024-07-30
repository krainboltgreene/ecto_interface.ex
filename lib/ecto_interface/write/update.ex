defmodule EctoInterface.Write.Update do
  @moduledoc false
  defmacro __using__([schema, singular, update_changeset_function])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Applies a `value` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2`  and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(unquote(schema).t(), any()) ::
              unquote(schema).t()
      def unquote(:"update_#{singular}!")(record, value, options \\ [])
          when is_struct(record, unquote(schema)) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(value, unquote(update_changeset_function))
        |> Application.get_env(:ecto_interface, :default_repo).update!(options)
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
      end

      @doc """
      Applies a `value` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}_by!")(
              unquote(schema).t(),
              any(),
              function()
            ) ::
              unquote(schema).t()
      def unquote(:"update_#{singular}_by!")(
            record,
            value,
            changeset_function,
            options \\ []
          )
          when is_struct(record, unquote(schema)) and is_function(changeset_function, 2) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(value, changeset_function)
        |> Application.get_env(:ecto_interface, :default_repo).update!(options)
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
      end

      @doc """
      Applies a `value` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"update_#{singular}")(unquote(schema).t(), any(), Keyword.t(list())) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}")(record, value, options \\ [])
          when is_struct(record, unquote(schema)) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(value, unquote(update_changeset_function))
        |> Application.get_env(:ecto_interface, :default_repo).update(options)
        |> case do
          {:ok, record} ->
            {:ok, Application.get_env(:ecto_interface, :default_repo).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end

      @doc """
      Applies a `value` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.
      """
      @spec unquote(:"update_#{singular}_by")(
              unquote(schema).t(),
              any(),
              function()
            ) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}_by")(record, value, changeset_function, options \\ [])
          when is_struct(record, unquote(schema)) and is_function(changeset_function, 2) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(value, changeset_function)
        |> Application.get_env(:ecto_interface, :default_repo).update(options)
        |> case do
          {:ok, record} ->
            {:ok, Application.get_env(:ecto_interface, :default_repo).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end
    end
  end
end
