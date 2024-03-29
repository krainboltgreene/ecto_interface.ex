defmodule EctoInterface.Read.Tagged do
  @moduledoc false
  defmacro __using__([schema, plural])
           when is_atom(plural) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns all `#{unquote(schema)}` records that have *all* of the given tags
      """
      @spec unquote(:"list_#{plural}_with_tags")(list(String.t())) ::
              list(unquote(schema).t())
      def unquote(:"list_#{plural}_with_tags")([], options \\ []),
        do: []

      def unquote(:"list_#{plural}_with_tags")(tags, options \\ []) when is_list(tags) do
        from(
          record in unquote(schema),
          join: tag in assoc(record, :tags),
          having: fragment("? @> ?", fragment("array_agg(?)", tag.slug), ^tags),
          group_by: record.id
        )
        |> Application.get_env(:ecto_interface, :default_repo).all(options)
      end
    end
  end
end
