defmodule EctoInterface.PubSub do
  @moduledoc """
  A group of helper methods for broadcasting/listening to data through a pubsub system.
  """
  defmacro __using__(options)
           when is_list(options) do
    source =
      Keyword.get(options, :source) ||
        raise "Missing :source key in use(EctoInterface.Pubsub) call"

    plural =
      Keyword.get(options, :plural) ||
        raise "Missing :plural key in use(EctoInterface.Pubsub) call"

    singular =
      Keyword.get(options, :singular) ||
        raise "Missing :singular key in use(EctoInterface.Pubsub) call"

    pubsub =
      Keyword.get(
        options,
        :pubsub,
        Application.get_env(:ecto_interface, :default_pubsub, false)
      ) ||
        raise "Missing :pubsub key in use(EctoInterface.Pubsub) call OR missing :default_pubsub configuration"

    quote(location: :keep) do
      @doc """
      Subscribes to the various #{unquote(singular)} messages.
      """
      @spec unquote(:"subscribe_to_#{plural}")() :: :ok
      def unquote(:"subscribe_to_#{plural}")(),
        do:
          unquote(pubsub)
          |> Phoenix.PubSub.subscribe(Enum.join([__MODULE__, unquote(plural)], "/"))

      @doc """
      Broadcasts an insert of the specified `record` to anyone who is listening. The event payload name
      is `:changed` and the payload is `{:#{unquote(singular)}, id}`.
      """
      @spec unquote(:"broadcast_#{plural}_insert")(unquote(source).t()) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_insert")(%unquote(source){id: id}),
        do:
          unquote(pubsub)
          |> Phoenix.PubSub.broadcast(
            Enum.join([__MODULE__, unquote(plural)], "/"),
            {:inserted, {unquote(singular), id}}
          )

      @doc """
      Broadcasts a change of the specified `record` to anyone who is listening. The event payload name
      is `:changed` and the payload is `{:#{unquote(singular)}, id}`.
      """
      @spec unquote(:"broadcast_#{plural}_change")(unquote(source).t()) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_change")(%unquote(source){id: id}),
        do:
          unquote(pubsub)
          |> Phoenix.PubSub.broadcast(
            Enum.join([__MODULE__, unquote(plural)], "/"),
            {:changed, {unquote(singular), id}}
          )
    end
  end
end
