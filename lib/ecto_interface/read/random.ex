defmodule EctoInterface.Read.Random do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__([schema, plural, singular])
           when is_atom(plural) and is_atom(singular) do
    quote(location: :keep) do
      import Ecto.Query

      @doc """
      Randomly selects a `#{unquote(schema)}` record based on a set of conditions
      """
      @spec unquote(:"random_#{singular}")((Ecto.Query.t() -> Ecto.Query.t())) ::
              unquote(schema).t() | nil
      def unquote(:"random_#{singular}")(subquery) when is_function(subquery, 1) do
        subquery.(from(unquote(schema)))
        |> from(limit: 1, order_by: fragment("random()"))
        |> Application.get_env(:ecto_interface, :default_repo).one()
      end

      @doc """
      Randomly selects a `#{unquote(schema)}` record
      """
      @spec unquote(:"random_#{singular}")() :: unquote(schema).t() | nil
      def unquote(:"random_#{singular}")() do
        unquote(schema)
        |> from(limit: 1, order_by: fragment("random()"))
        |> Application.get_env(:ecto_interface, :default_repo).one()
      end

      @doc """
      Randomly selects `count` `#{unquote(schema)}` records based on a set of conditions
      """
      @spec unquote(:"random_#{plural}")(integer(), (Ecto.Query.t() -> Ecto.Query.t())) ::
              list(unquote(schema).t())
      def unquote(:"random_#{plural}")(count, subquery)
          when is_integer(count) and is_function(subquery, 1) do
        subquery.(from(unquote(schema)))
        |> from(limit: ^count, order_by: fragment("random()"))
        |> Application.get_env(:ecto_interface, :default_repo).all()
      end

      @doc """
      Randomly selects `count` `#{unquote(schema)}` records.
      """
      @spec unquote(:"random_#{plural}")(integer()) :: list(unquote(schema).t())
      def unquote(:"random_#{plural}")(count) when is_integer(count) do
        unquote(schema)
        |> from(limit: ^count, order_by: fragment("random()"))
        |> Application.get_env(:ecto_interface, :default_repo).all()
      end
    end
  end
end
