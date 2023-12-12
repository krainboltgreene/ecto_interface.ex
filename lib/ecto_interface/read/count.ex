defmodule EctoInterface.Read.Count do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural])
           when is_atom(plural) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Counts the number of `#{unquote(schema)}` records in the databas  based on a set of conditions.
      """
      @spec unquote(:"count_#{plural}")((Ecto.Query.t() -> Ecto.Query.t())) :: integer()
      def unquote(:"count_#{plural}")(subquery) when is_function(subquery, 1) do
        Application.get_env(:ecto_interface, :default_repo).aggregate(
          subquery.(from(unquote(schema))),
          :count,
          :id
        )
      end

      @doc """
      Counts the number of `#{unquote(schema)}` records in the database.
      """
      @spec unquote(:"count_#{plural}")() :: integer()
      def unquote(:"count_#{plural}")() do
        Application.get_env(:ecto_interface, :default_repo).aggregate(
          unquote(schema),
          :count,
          :id
        )
      end
    end
  end
end
