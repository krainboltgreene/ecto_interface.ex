defmodule EctoInterface do
  @moduledoc """
  EctoInterface is a suite of commonly defined APIs for Ecto-based models. Almost all of these came from the normal
  generated content in a new phoenix project, simply unifying and expanding on that suite.
  """

  @doc """
  Using this expression in your context module:

      use(EctoInterface, source: Core.Commerce.Product, plural: :products, :product])

  Will automatically define a whole suite of functions for that schema.

  You can also get specific about which changesets are used (default is schema.changeset/2):

      use(EctoInterface, source: Core.Commerce.Product, plural: :products, :product, changeset: :simple_changeset])

  And also if you need to differentiate between insert and update changesets:

      use(EctoInterface, source: Core.Commerce.Product, plural: :products, :product, insert_by: :create_changeset, update_by: :update_changeset])
  """

  defmacro __using__(options) do
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

    pubsub =
      Keyword.get(
        options,
        :pubsub,
        Application.get_env(:ecto_interface, :default_pubsub, false)
      )

    slug = Keyword.get(options, :slug, false)
    tagged = Keyword.get(options, :tagged, false)

    [
      quote do
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

        use EctoInterface.Write.Create,
          source: unquote(source),
          singular: unquote(singular),
          repo: unquote(repo)

        use EctoInterface.Write.Update,
          source: unquote(source),
          singular: unquote(singular),
          repo: unquote(repo)

        use EctoInterface.Write.Delete,
          source: unquote(source),
          singular: unquote(singular),
          repo: unquote(repo)
      end,
      if pubsub do
        quote do
          use EctoInterface.PubSub,
            plural: unquote(plural),
            singular: unquote(singular),
            pubsub: unquote(pubsub)
        end
      end,
      if tagged do
        quote do
          use EctoInterface.Read.Tagged,
            source: unquote(source),
            plural: unquote(plural),
            singular: unquote(singular),
            tagged: unquote(tagged)
        end
      end,
      if slug do
        quote do
          use EctoInterface.Read.Slug,
            source: unquote(source),
            singular: unquote(singular),
            slug: unquote(slug)
        end
      end
    ]
  end

  def expand_alias({:__aliases__, _, _} = alias, env) when is_struct(env, Macro.Env) do
    Module.concat(env.module, Macro.expand(alias, %{env | function: {:init, 1}}))
  end
end
