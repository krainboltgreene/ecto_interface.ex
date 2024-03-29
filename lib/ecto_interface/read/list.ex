defmodule EctoInterface.Read.List do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural])
           when is_atom(plural) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Returns all `#{unquote(schema)}` records from a modified query
      """
      @spec unquote(:"list_#{plural}")((Ecto.Query.t() -> Ecto.Query.t())) ::
              list(unquote(schema))
      def unquote(:"list_#{plural}")(subquery) when is_function(subquery, 1),
        do:
          subquery.(from(unquote(schema)))
          |> Application.get_env(:ecto_interface, :default_repo).all()

      @doc """
      Returns all `#{unquote(schema)}` records, unsorted
      """
      @spec unquote(:"list_#{plural}")() :: list(unquote(schema).t())
      def unquote(:"list_#{plural}")(),
        do: from(unquote(schema)) |> Application.get_env(:ecto_interface, :default_repo).all()

      @doc """
      Returns a stream of `#{unquote(schema)}` records from a modified query
      """
      @spec unquote(:"stream_#{plural}")((Ecto.Query.t() -> Ecto.Query.t())) ::
              Enum.t()
      def unquote(:"stream_#{plural}")(subquery) when is_function(subquery, 1),
        do:
          subquery.(from(unquote(schema)))
          |> Application.get_env(:ecto_interface, :default_repo).all()

      @doc """
      Returns a stream of `#{unquote(schema)}` records, unsorted
      """
      @spec unquote(:"stream_#{plural}")() :: Enum.t()
      def unquote(:"stream_#{plural}")(),
        do: from(unquote(schema)) |> Application.get_env(:ecto_interface, :default_repo).stream()
    end
  end
end
