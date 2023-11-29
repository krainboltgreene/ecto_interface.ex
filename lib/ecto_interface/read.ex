defmodule EctoInterface.Read do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural, singular])
           when is_atom(plural) and is_atom(singular) do
    quote(location: :keep) do
      use EctoInterface.Read.Count, [unquote(schema), unquote(plural)]
      use EctoInterface.Read.Get, [unquote(schema), unquote(plural), unquote(singular)]
      use EctoInterface.Read.List, [unquote(schema), unquote(plural)]
      use EctoInterface.Read.Random, [unquote(schema), unquote(plural), unquote(singular)]
    end
  end
end
