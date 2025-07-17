defmodule EctoInterface.Read.Tagged do
  @moduledoc false
  defmacro __using__(options)
           when is_list(options) do
    source =
      Keyword.get(options, :source) ||
        raise "Missing :source key in use(EctoInterface) call"

    plural =
      Keyword.get(options, :plural) ||
        raise "Missing :plural key in use(EctoInterface) call"

    repo =
      Keyword.get(
        options,
        :repo,
        Application.get_env(:ecto_interface, :default_repo)
      ) ||
        raise "Missing :repo key in use(EctoInterface) call OR missing :default_repo in configuration"

    tagged =
      Keyword.get(options, :tagged) ||
        raise "Missing :tagged key in use(EctoInterface) call"

    quote do
      import Ecto.Query

      @doc """
      Returns all `#{__MODULE__.unquote(source)}` records that have *all* of the given tags
      """
      @spec unquote(:"list_#{plural}_with_tags")(list(String.t())) ::
              list(__MODULE__.unquote(source).t())
      @spec unquote(:"list_#{plural}_with_tags")(list(String.t()), Keyword.t()) ::
              list(__MODULE__.unquote(source).t())
      def unquote(:"list_#{plural}_with_tags")(tags, options \\ [])

      def unquote(:"list_#{plural}_with_tags")([], options),
        do: []

      def unquote(:"list_#{plural}_with_tags")(tags, options) when is_list(tags) do
        from(
          record in __MODULE__.unquote(source),
          join: tag in assoc(record, unquote(tagged)),
          having: fragment("? @> ?", fragment("array_agg(?)", tag.slug), ^tags),
          group_by: record.id
        )
        |> unquote(repo).all(options)
      end
    end
  end
end
