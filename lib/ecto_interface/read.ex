defmodule EctoInterface.Read do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__(options) when is_list(options) do
    source =
      Keyword.get(options, :source) ||
        raise "Missing :source key in use(EctoInterface) call"

    plural =
      Keyword.get(options, :plural) ||
        raise "Missing :plural key in use(EctoInterface) call"

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

    slug = Keyword.get(options, :slug, false)
    tagged = Keyword.get(options, :tagged, false)

    quote(location: :keep) do
      use EctoInterface.Read.Count,
        source: unquote(source),
        plural: unquote(plural),
        repo: unquote(repo)

      use EctoInterface.Read.Get,
        source: unquote(source),
        plural: unquote(plural),
        singular: unquote(singular),
        repo: unquote(repo)

      use EctoInterface.Read.List,
        source: unquote(source),
        plural: unquote(plural),
        repo: unquote(repo)

      use EctoInterface.Read.Random,
        source: unquote(source),
        plural: unquote(plural),
        singular: unquote(singular),
        repo: unquote(repo)

      if unquote(tagged) do
        use EctoInterface.Read.Tagged,
          source: unquote(source),
          singular: unquote(singular),
          tagged: unquote(tagged)
      end

      if unquote(slug) do
        use EctoInterface.Read.Slug,
          source: unquote(source),
          plural: unquote(plural),
          slug: unquote(slug)
      end
    end
  end
end
