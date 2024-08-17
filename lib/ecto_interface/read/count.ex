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
      @spec unquote(:"count_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t())) :: integer()
      @spec unquote(:"count_#{plural}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              integer()
      def unquote(:"count_#{plural}_by")(subquery, options \\ [])
          when is_function(subquery, 1) and is_list(options) do
        Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).aggregate(
          subquery.(unquote(schema)),
          :count,
          :id,
          options
        )
      end

      @doc """
      Counts the number of `#{unquote(schema)}` records in the database.
      """
      @spec unquote(:"count_#{plural}")() :: integer()
      @spec unquote(:"count_#{plural}")(Keyword.t()) :: integer()
      def unquote(:"count_#{plural}")(options \\ []) when is_list(options) do
        Application.get_env(:ecto_interface, unquote(schema), Application.get_env(:ecto_interface, :default_repo)).aggregate(
          unquote(schema),
          :count,
          :id,
          options
        )
      end
    end
  end
end
