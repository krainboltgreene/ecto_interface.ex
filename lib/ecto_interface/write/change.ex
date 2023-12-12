defmodule EctoInterface.Write.Change do
  @moduledoc false
  defmacro __using__([schema, singular, insert_changeset_function, update_changeset_function])
           when is_atom(singular) and is_atom(insert_changeset_function) and
                  is_atom(update_changeset_function) do
    quote(location: :keep) do
      @doc """
      Creates an empty `#{unquote(schema)}` and applies no attributes to it via `#{unquote(schema)}.#{unquote(insert_changeset_function)}/2`
      """
      @spec unquote(:"new_#{singular}")(map()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"new_#{singular}")(attributes \\ %{}),
        do: unquote(:"new_#{singular}")(%unquote(schema){}, attributes)

      @doc """
      Takes an empty `#{unquote(schema)}` and applies `attributes` to it via `#{unquote(schema)}.#{unquote(insert_changeset_function)}/2`
      """
      @spec unquote(:"new_#{singular}")(struct(), map()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"new_#{singular}")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do: unquote(schema).unquote(insert_changeset_function)(record, attributes)

      @doc """
      Takes an existing `#{unquote(schema)}` and applies `attributes` to it via `#{unquote(schema)}.#{unquote(update_changeset_function)}/2`.
      """
      @spec unquote(:"change_#{singular}")(unquote(schema).t(), map()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"change_#{singular}")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do: unquote(schema).unquote(update_changeset_function)(record, attributes)
    end
  end
end
