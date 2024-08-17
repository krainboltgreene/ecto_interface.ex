defmodule EctoInterface.Write.Create do
  @moduledoc false
  defmacro __using__([schema, singular, insert_changeset_function])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Applies a `value` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/3` and then inserts the changeset into the database. Allows for a list of
      preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}!")(any()) :: unquote(schema).t()
      @spec unquote(:"create_#{singular}!")(any(), Keyword.t()) :: unquote(schema).t()
      def unquote(:"create_#{singular}!")(value, options \\ []) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(preload)
        |> unquote(:"new_#{singular}")(value, unquote(insert_changeset_function))
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).insert!(options)
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(preload)
      end

      @doc """
      Applies a `value` to a empty `#{unquote(schema)}` via
      `#{unquote(:"change_#{singular}")}/3` using `changeset` and then inserts resulting changeset into the database.
      Allows for a list of preloaded relationships by passing `preload: []`.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}_by!")(any(), function()) ::
              unquote(schema).t()
      @spec unquote(:"create_#{singular}_by!")(any(), function(), Keyword.t()) ::
              unquote(schema).t()
      def unquote(:"create_#{singular}_by!")(value, changeset_function, options \\ [])
          when is_function(changeset_function) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(preload)
        |> unquote(:"change_#{singular}")(
          value,
          changeset_function
        )
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).insert!(options)
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(preload)
      end

      @doc """
      Applies a `value` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/3`  and then inserts the changeset into the database. Allows for a list of
      preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"create_#{singular}")(any()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      @spec unquote(:"create_#{singular}")(any(), Keyword.t()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}")(value, options \\ []) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(preload)
        |> unquote(:"new_#{singular}")(value, unquote(insert_changeset_function))
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).insert(options)
        |> case do
          {:ok, record} ->
            {:ok, Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end

      @doc """
      Applies a `value` to a empty `#{unquote(schema)}` via
      `#{unquote(:"change_#{singular}")}/3` using `changeset` and then inserts resulting changeset into the database.
      Allows for a list of preloaded relationships by passing `preload: []`.
      """
      @spec unquote(:"create_#{singular}_by")(any(), function()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      @spec unquote(:"create_#{singular}_by")(any(), function(), Keyword.t()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}_by")(value, changeset_function, options \\ [])
          when is_function(changeset_function) do
        {preload, options} = Keyword.pop(options, :preload, [])

        %unquote(schema){}
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(preload)
        |> unquote(:"change_#{singular}")(value, changeset_function)
        |> Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).insert(options)
        |> case do
          {:ok, record} ->
            {:ok, Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).preload(record, preload)}

          otherwise ->
            otherwise
        end
      end
    end
  end
end
