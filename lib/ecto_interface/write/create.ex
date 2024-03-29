defmodule EctoInterface.Write.Create do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/2` and then inserts the changeset into the database. Allows for a list of
      preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}!")(map()) :: unquote(schema).t()
      def unquote(:"create_#{singular}!")(attributes, options \\ [])
          when is_map(attributes) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"new_#{singular}")(attributes)
        |> Application.get_env(:ecto_interface, :default_repo).insert!(options)
      end

      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"change_#{singular}")}/2` using `changeset` and then inserts resulting changeset into the database.
      Allows for a list of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}_by!")(map(), function()) ::
              unquote(schema).t()
      def unquote(:"create_#{singular}_by!")(attributes, changeset_function, options \\ [])
          when is_map(attributes) and is_function(changeset_function) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(
          attributes,
          changeset_function
        )
        |> Application.get_env(:ecto_interface, :default_repo).insert!(options)
      end

      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/2`  and then inserts the changeset into the database. Allows for a list of
      preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"create_#{singular}")(map()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}")(attributes, options \\ [])
          when is_map(attributes) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"new_#{singular}")(attributes)
        |> Application.get_env(:ecto_interface, :default_repo).insert(options)
      end

      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"change_#{singular}")}/2` using `changeset` and then inserts resulting changeset into the database.
      Allows for a list of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"create_#{singular}_by")(map(), function()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}_by")(attributes, changeset_function, options \\ [])
          when is_map(attributes) and is_function(changeset_function) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
        |> unquote(:"change_#{singular}")(attributes, changeset_function)
        |> Application.get_env(:ecto_interface, :default_repo).insert(options)
      end
    end
  end
end
