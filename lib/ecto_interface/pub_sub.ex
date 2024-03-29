defmodule EctoInterface.PubSub do
  @moduledoc """
  A group of helper methods for broadcasting/listening to data through a pubsub system.
  """
  defmacro __using__([schema, plural, singular])
           when is_atom(singular) and is_atom(plural) do
    quote(location: :keep) do
      @doc """
      Subscribes to the various #{unquote(singular)} messages.
      """
      @spec unquote(:"subscribe_to_#{plural}")() :: :ok
      def unquote(:"subscribe_to_#{plural}")(),
        do:
          Application.get_env(:ecto_interface, :default_pubsub)
          |> Phoenix.PubSub.subscribe(Enum.join([__MODULE__, unquote(plural)], "/"))

      @doc """
      Broadcasts an insert of the specified `record` to anyone who is listening. The event payload name
      is `:changed` and the payload is `{:#{unquote(singular)}, id}`.
      """
      @spec unquote(:"broadcast_#{plural}_insert")(unquote(schema).t()) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_insert")(%unquote(schema){id: id}),
        do:
          Application.get_env(:ecto_interface, :default_pubsub)
          |> Phoenix.PubSub.broadcast(
            Enum.join([__MODULE__, unquote(plural)], "/"),
            {:inserted, {unquote(singular), id}}
          )

      @doc """
      Broadcasts a change of the specified `record` to anyone who is listening. The event payload name
      is `:changed` and the payload is `{:#{unquote(singular)}, id}`.
      """
      @spec unquote(:"broadcast_#{plural}_change")(unquote(schema).t()) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_change")(%unquote(schema){id: id}),
        do:
          Application.get_env(:ecto_interface, :default_pubsub)
          |> Phoenix.PubSub.broadcast(
            Enum.join([__MODULE__, unquote(plural)], "/"),
            {:changed, {unquote(singular), id}}
          )
    end
  end
end
