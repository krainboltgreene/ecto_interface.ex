defmodule EctoInterface.Read.Slug do
  @moduledoc """
  If you have Slugy installed you can use these functions to find a record by it's slug
  """
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns a singular `#{unquote(schema)}` based on the slug column, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}_by_slug!")(String.t()) :: unquote(schema).t()
      def unquote(:"get_#{singular}_by_slug!")(name_or_slug, options \\ [])
          when is_binary(name_or_slug),
          do:
            unquote(schema)
            |> from(where: [slug: ^Slugy.slugify(name_or_slug)], limit: 1)
            |> Application.get_env(:ecto_interface, :default_repo).one!(options)

      @doc """
      Returns a singular `#{unquote(schema)}` based on the slug column and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}_by_slug")(String.t()) :: unquote(schema).t() | nil
      def unquote(:"get_#{singular}_by_slug")(name_or_slug, options \\ [])
          when is_binary(name_or_slug),
          do:
            unquote(schema)
            |> from(where: [slug: ^Slugy.slugify(name_or_slug)], limit: 1)
            |> Application.get_env(:ecto_interface, :default_repo).one(options)
    end
  end
end
