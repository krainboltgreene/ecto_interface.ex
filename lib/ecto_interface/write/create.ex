defmodule EctoInterface.Write.Create do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/2` and then inserts the changeset into the database. Allows for a list of
      preloaded relationships.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}!")(map(), Keyword.t(list())) :: unquote(schema).t()
      def unquote(:"create_#{singular}!")(attributes, preload: preload)
          when is_map(attributes) and is_list(preload),
          do:
            %unquote(schema){}
            |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
            |> unquote(:"new_#{singular}")(attributes)
            |> Application.get_env(:ecto_interface, :default_repo).insert!()

      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/2`  and then inserts the changeset into the database. Allows for a list of
      preloaded relationships.
      """
      @spec unquote(:"create_#{singular}")(map(), Keyword.t(list())) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}")(attributes, preload: preload)
          when is_map(attributes) and is_list(preload),
          do:
            %unquote(schema){}
            |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
            |> unquote(:"new_#{singular}")(attributes)
            |> Application.get_env(:ecto_interface, :default_repo).insert()

      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/2` and then inserts the changeset into the database.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}!")(map()) :: unquote(schema).t()
      def unquote(:"create_#{singular}!")(attributes \\ %{}) when is_map(attributes),
        do:
          %unquote(schema){}
          |> unquote(:"new_#{singular}")(attributes)
          |> Application.get_env(:ecto_interface, :default_repo).insert!()

      @doc """
      Applies a set of `attributes` to a empty `#{unquote(schema)}` via
      `#{unquote(:"new_#{singular}")}/2`  and then inserts the changeset into the database.
      """
      @spec unquote(:"create_#{singular}")(map()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}")(attributes \\ %{}) when is_map(attributes),
        do:
          %unquote(schema){}
          |> unquote(:"new_#{singular}")(attributes)
          |> Application.get_env(:ecto_interface, :default_repo).insert()
    end
  end
end
