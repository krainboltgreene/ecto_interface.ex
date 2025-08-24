defmodule EctoInterface.Read.Random do
  @moduledoc """
  All functions that help read data from the database.
  """
  defmacro __using__(options)
           when is_list(options) do
    source =
      EctoInterface.expand_alias(
        Keyword.get(options, :source) ||
          raise("Missing :source key in use(EctoInterface) call"),
        __CALLER__
      )

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

    quote do
      import Ecto.Query

      @doc """
      Randomly selects a `#{unquote(source)}` record based on a set of conditions
      """
      @spec unquote(:"random_#{singular}_by")((Ecto.Query.t() -> Ecto.Query.t())) ::
              unquote(source).t() | nil
      @spec unquote(:"random_#{singular}_by")((Ecto.Query.t() -> Ecto.Query.t()), Keyword.t()) ::
              unquote(source).t() | nil
      def unquote(:"random_#{singular}_by")(subquery, options \\ [])
          when is_function(subquery, 1) do
        subquery.(from(unquote(source)))
        |> from(limit: 1, order_by: fragment("random()"))
        |> unquote(repo).one(options)
      end

      @doc """
      Randomly selects a `#{unquote(source)}` record
      """
      @spec unquote(:"random_#{singular}")() :: unquote(source).t() | nil
      @spec unquote(:"random_#{singular}")(Keyword.t()) :: unquote(source).t() | nil
      def unquote(:"random_#{singular}")(options \\ []) do
        unquote(source)
        |> from(limit: 1, order_by: fragment("random()"))
        |> unquote(repo).one(options)
      end

      @doc """
      Randomly selects `count` `#{unquote(source)}` records based on a set of conditions
      """
      @spec unquote(:"random_#{plural}_by")(integer(), (Ecto.Query.t() -> Ecto.Query.t())) ::
              list(unquote(source).t())
      @spec unquote(:"random_#{plural}_by")(
              integer(),
              (Ecto.Query.t() -> Ecto.Query.t()),
              Keyword.t()
            ) ::
              list(unquote(source).t())
      def unquote(:"random_#{plural}_by")(count, subquery, options \\ [])
          when is_integer(count) and is_function(subquery, 1) do
        subquery.(from(unquote(source)))
        |> from(limit: ^count, order_by: fragment("random()"))
        |> unquote(repo).all(options)
      end

      @doc """
      Randomly selects `count` `#{unquote(source)}` records.
      """
      @spec unquote(:"random_#{plural}")(integer()) :: list(unquote(source).t())
      @spec unquote(:"random_#{plural}")(integer(), Keyword.t()) ::
              list(unquote(source).t())
      def unquote(:"random_#{plural}")(count, options \\ []) when is_integer(count) do
        unquote(source)
        |> from(limit: ^count, order_by: fragment("random()"))
        |> unquote(repo).all(options)
      end
    end
  end
end
