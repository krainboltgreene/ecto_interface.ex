defmodule EctoInterface.Write.Update do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships.
      """
      @spec unquote(:"update_#{singular}")(unquote(schema).t(), map(), Keyword.t(list())) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}")(record, attributes, preload: preload)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do:
            record
            |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
            |> unquote(:"change_#{singular}")(attributes)
            |> Application.get_env(:ecto_interface, :default_repo).update()

      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2`  and then updates with the subsequent changeset. Allows for a
      set of preloaded relationships.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(unquote(schema).t(), map(), Keyword.t(list())) ::
              unquote(schema).t()
      def unquote(:"update_#{singular}!")(record, attributes, preload: preload)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do:
            record
            |> Application.get_env(:ecto_interface, :default_repo).preload(preload)
            |> unquote(:"change_#{singular}")(attributes)
            |> Application.get_env(:ecto_interface, :default_repo).update!()

      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2` and then updates with the subsequent changeset.
      """
      @spec unquote(:"update_#{singular}")(unquote(schema).t(), map()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do:
            record
            |> unquote(:"change_#{singular}")(attributes)
            |> Application.get_env(:ecto_interface, :default_repo).update()

      @doc """
      Applies a set of `attributes` to the given `record`, a `#{unquote(schema)}`, via
      `#{unquote(:"change_#{singular}")}/2`  and then updates with the subsequent changeset.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(unquote(schema).t(), map()) :: unquote(schema).t()
      def unquote(:"update_#{singular}!")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do:
            record
            |> unquote(:"change_#{singular}")(attributes)
            |> Application.get_env(:ecto_interface, :default_repo).update!()
    end
  end
end
