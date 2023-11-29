defmodule EctoInterface do
  @moduledoc """
  EctoInterface is a suite of commonly defined APIs for Ecto-based models. Almost all of these came from the normal
  generated content in a new phoenix project, simply unifying and expanding on that suite.
  """

  @doc """
  Using this expression in your context module:

      use(EctoInterface, [Core.Commerce.Product, :products, :product])

  Will automatically define a whole suite of functions for that schema.

  You can also get specific about which changesets are used (default is schema.changeset/1):

      use(EctoInterface, [Core.Commerce.Product, :products, :product, :simple_changeset])

  And also if you need to differentiate between insert and update changesets:

      use(EctoInterface, [Core.Commerce.Product, :products, :product, :create_changeset, :update_changeset])
  """
  defmacro __using__([
             schema,
             plural,
             singular,
             insert_changeset_function,
             update_changeset_function
           ]) do
    quote(location: :keep) do
      use EctoInterface.Read, [unquote(schema), unquote(plural), unquote(singular)]

      use EctoInterface.Write, [
        unquote(schema),
        unquote(singular),
        unquote(insert_changeset_function),
        unquote(update_changeset_function)
      ]
    end
  end

  defmacro __using__([schema, plural, singular, changeset_function]) do
    quote(location: :keep) do
      use EctoInterface, [
        unquote(schema),
        unquote(plural),
        unquote(singular),
        unquote(changeset_function),
        unquote(changeset_function)
      ]
    end
  end

  defmacro __using__([schema, plural, singular]) do
    quote(location: :keep) do
      use EctoInterface, [
        unquote(schema),
        unquote(plural),
        unquote(singular),
        :changeset,
        :changeset
      ]
    end
  end
end
