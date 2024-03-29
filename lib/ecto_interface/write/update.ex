defmodule EctoInterface.Write.Update do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2`  and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(unquote(schema).t(), map()) ::
              unquote(schema).t()
      def unquote(:"update_#{singular}!")(record, attributes, options \\ [])
          when is_struct(record, unquote(schema)) and is_map(attributes) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(attributes)
        |> Application.get_env(:ecto_interface, :default_repo).update!(options)
      end

      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}_by!")(
              unquote(schema).t(),
              map(),
              function()
            ) ::
              unquote(schema).t()
      def unquote(:"update_#{singular}_by!")(
            record,
            attributes,
            changeset_function,
            options \\ []
          )
          when is_struct(record, unquote(schema)) and is_function(changeset_function, 2) and
                 is_map(attributes) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(attributes, changeset_function)
        |> Application.get_env(:ecto_interface, :default_repo).update!(options)
      end

      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"update_#{singular}")(unquote(schema).t(), map(), Keyword.t(list())) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}")(record, attributes, options \\ [])
          when is_struct(record, unquote(schema)) and is_map(attributes) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(attributes)
        |> Application.get_env(:ecto_interface, :default_repo).update(options)
      end

      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` with the `changeset_function` function, then updates the database with the
      subsequent changeset. Allows for a set of preloaded relationships.
      """
      @spec unquote(:"update_#{singular}_by")(
              unquote(schema).t(),
              map(),
              function()
            ) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}_by")(record, attributes, changeset_function, options \\ [])
          when is_struct(record, unquote(schema)) and is_function(changeset_function, 2) and
                 is_map(attributes) do
        {preload, options} = Keyword.pop(options, :preload, [])

        record
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(attributes, changeset_function)
        |> Application.get_env(:ecto_interface, :default_repo).update(options)
      end
    end
  end
end
