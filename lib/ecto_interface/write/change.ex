defmodule EctoInterface.Write.Change do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote(location: :keep) do
      @doc """
      Takes a `#{unquote(schema)}` and applies the `value` to it via the `changeset_function` function given
      """
      @spec unquote(:"new_#{singular}")(unquote(schema).t(), any(), function()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"new_#{singular}")(record, attributes, changeset_function)
          when is_map(attributes) and is_function(changeset_function),
          do: changeset_function.(record, attributes)

      @doc """
      Creates an empty `#{unquote(schema)}` and applies the `value` to it via the `changeset_function` function given
      """
      @spec unquote(:"new_#{singular}")(any(), function()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"new_#{singular}")(attributes, changeset_function)
          when is_map(attributes) and is_function(changeset_function),
          do: changeset_function.(%unquote(schema){}, attributes)

      @doc """
      Takes a `#{unquote(schema)}` and applies the `value` to it via the `changeset_function` function given. The `value` can be anything that the `changeset_function` takes.
      """
      @spec unquote(:"change_#{singular}")(
              unquote(schema).t() | Ecto.Changeset.t(unquote(schema).t()),
              any(),
              function()
            ) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"change_#{singular}")(record, attributes, changeset_function)
          when is_struct(record, unquote(schema)) and is_map(attributes) and
                 is_function(changeset_function),
          do: changeset_function.(record, attributes)
    end
  end
end
