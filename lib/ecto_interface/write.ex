defmodule EctoInterface.Write do
  @moduledoc false
  defmacro __using__(options)
           when is_list(options) do
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

    quote(location: :keep) do
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
    end
  end
end
