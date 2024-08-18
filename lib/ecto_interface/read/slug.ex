defmodule EctoInterface.Read.Slug do
  @moduledoc """
  If you have Slugy installed you can use these functions to find a record by it's slug
  """
  defmacro __using__(options)
           when is_list(options) do
    source =
      Keyword.get(options, :source) ||
        raise "Missing :source key in use(EctoInterface) call"

    singular =
      Keyword.get(options, :singular) ||
        raise "Missing :singular key in use(EctoInterface) call"

    repo =
      Keyword.get(
        options,
        :repo,
        Application.get_env(:ecto_interface, :default_repo)
      ) ||
        raise "Missing :repo key in use(EctoInterface) call OR missing :default_repo in configuration"

    slug =
      Keyword.get(options, :slug) ||
        raise "Missing :slug key in use(EctoInterface) call"

    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns a singular `#{unquote(source)}` based on the slug column, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}_by_slug!")(String.t()) :: unquote(source).t()
      @spec unquote(:"get_#{singular}_by_slug!")(String.t(), Keyword.t()) :: unquote(source).t()
      def unquote(:"get_#{singular}_by_slug!")(name_or_slug, options \\ [])
          when is_binary(name_or_slug),
          do:
            unquote(source)
            |> from(where: [{unquote(slug), ^Slugy.slugify(name_or_slug)}], limit: 1)
            |> unquote(repo).one!(options)

      @doc """
      Returns a singular `#{unquote(source)}` based on the slug column and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}_by_slug")(String.t()) :: unquote(source).t() | nil
      @spec unquote(:"get_#{singular}_by_slug")(String.t(), Keyword.t()) ::
              unquote(source).t() | nil
      def unquote(:"get_#{singular}_by_slug")(name_or_slug, options \\ [])
          when is_binary(name_or_slug),
          do:
            unquote(source)
            |> from(where: [{unquote(slug), ^Slugy.slugify(name_or_slug)}], limit: 1)
            |> unquote(repo).one(options)
    end
  end
end
