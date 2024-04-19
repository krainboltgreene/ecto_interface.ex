defmodule EctoInterface.Write do
  @moduledoc false
  defmacro __using__([schema, singular, insert_changeset_function, update_changeset_function])
           when is_atom(singular) do
    quote(location: :keep) do
      use EctoInterface.Write.Create, [
        unquote(schema),
        unquote(singular),
        unquote(insert_changeset_function)
      ]

      use EctoInterface.Write.Update, [
        unquote(schema),
        unquote(singular),
        unquote(update_changeset_function)
      ]

      use EctoInterface.Write.Delete, [unquote(schema), unquote(singular)]

      use EctoInterface.Write.Change, [
        unquote(schema),
        unquote(singular)
      ]
    end
  end
end
