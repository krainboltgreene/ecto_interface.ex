defmodule EctoInterface.Write.Delete do
  @moduledoc false
  defmacro __using__(options) when is_list(options) do
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

    quote do
      @doc """
      Takes an `#{__MODULE__.unquote(source)}` and deletes it from the database.
      """
      @spec unquote(:"delete_#{singular}")(__MODULE__.unquote(source).t()) ::
              {:ok, __MODULE__.unquote(source).t()}
              | {:error, Ecto.Changeset.t(__MODULE__.unquote(source).t())}
      def unquote(:"delete_#{singular}")(record, options \\ [])
          when is_struct(record, __MODULE__.unquote(source)),
          do: unquote(repo).delete(record, options)

      @doc """
      Takes an `#{__MODULE__.unquote(source)}` and deletes it from the database.

      If the row can't be found or constraints prevent you from deleting the row, this will raise an exception.
      """
      @spec unquote(:"delete_#{singular}!")(__MODULE__.unquote(source).t()) ::
              __MODULE__.unquote(source).t()
      def unquote(:"delete_#{singular}!")(record, options \\ [])
          when is_struct(record, __MODULE__.unquote(source)),
          do: unquote(repo).delete!(record, options)
    end
  end
end
