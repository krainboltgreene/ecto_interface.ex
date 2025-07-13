defmodule EctoInterface.PubSub do
  @moduledoc """
  A group of helper methods for broadcasting/listening to data through a pubsub system.
  """
  defmacro __using__(options)
           when is_list(options) do
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

    quote do
      @doc """
      Subscribes to any messages broadcast to the #{__MODULE__} #{unquote(singular)} channel.
      """
      @spec unquote(:"subscribe_to_#{plural}")(Keyword.t() | nil) :: :ok
      def unquote(:"subscribe_to_#{plural}")(options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.subscribe(
            unquote(pubsub),
            Base.encode64(:erlang.term_to_binary({__MODULE__, unquote(plural), options}))
          )
        end

        Base.encode64(:erlang.term_to_binary({__MODULE__, unquote(plural)}))
      end

      @doc """
      Subscribes to any messages broadcast to the #{__MODULE__} #{unquote(singular)} record channel.
      """
      @spec unquote(:"subscribe_to_#{singular}")(
              atom() | integer() | String.t(),
              Keyword.t() | nil
            ) :: :ok
      def unquote(:"subscribe_to_#{singular}")(key, options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.subscribe(
            unquote(pubsub),
            Base.encode64(:erlang.term_to_binary({__MODULE__, unquote(singular), key, options}))
          )
        else
          Phoenix.PubSub.subscribe(
            unquote(pubsub),
            Base.encode64(:erlang.term_to_binary({__MODULE__, unquote(singular), key}))
          )
        end
      end

      @doc """
      Broadcasts an `inserted` event to any listeners. The payload is
      `{:#{unquote(singular)}, id}` or `{:#{unquote(singular)}, id, options}` (see below).

      For example lets say you subscribe to all #{unquote(singular)} broadcasts with:

          #{__MODULE__}.subscribe_to_#{unquote(plural)}()

      You can then define the listener:

          def handle_info(:inserted, {:#{unquote(plural)}, key}), do: # ...

      And broadcast via:

        #{__MODULE__}.broadcast_#{unquote(plural)}_change(#{unquote(singular)}.id)

      However if you want to pub/sub to a specific record:

          #{__MODULE__}.subscribe_to_#{unquote(singular)}(#{unquote(singular)}.id)

      The same listener will work. However if you want to narrow further you can pass a
      `options` keyword to the subscribe:

          #{__MODULE__}.subscribe_to_#{unquote(plural)}(prefix: "live", tenant: :johnny_tackle_shop)

      And to the broadcast:

          #{__MODULE__}.broadcast_#{unquote(plural)}_change(#{unquote(singular)}.id, prefix: "live", tenant: post.merchant.slug)

      You have to change your listener signature:

          def handle_info(:inserted, {:#{unquote(plural)}, key, _options}), do: # ...

      NOTE: The following subscription will also pick up the above broadcast, but obviously won't have the options:

          #{__MODULE__}.subscribe_to_#{unquote(singular)}(#{unquote(singular)}.id)
      """
      @spec unquote(:"broadcast_#{plural}_insert")(atom() | integer() | String.t(), atom()) ::
              :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_insert")(key, options \\ []) do
        do_broadcast_plural_event(
          unquote(pubsub),
          :inserted,
          key,
          unquote(plural),
          unquote(singular),
          options
        )
      end

      @doc """
      Broadcasts an `changed` event to any listeners. The payload is
      `{:#{unquote(singular)}, id}` or `{:#{unquote(singular)}, id, options}` (see below).

      For example lets say you subscribe to all #{unquote(singular)} broadcasts with:

          #{__MODULE__}.subscribe_to_#{unquote(plural)}()

      You can then define the listener:

          def handle_info(:changed, {:#{unquote(plural)}, key}), do: # ...

      And broadcast via:

        #{__MODULE__}.broadcast_#{unquote(plural)}_change(#{unquote(singular)}.id)

      However if you want to pub/sub to a specific record:

          #{__MODULE__}.subscribe_to_#{unquote(singular)}(#{unquote(singular)}.id)

      The same listener will work. However if you want to narrow further you can pass a
      `options` keyword to the subscribe:

          #{__MODULE__}.subscribe_to_#{unquote(plural)}(prefix: "live", tenant: :johnny_tackle_shop)

      And to the broadcast:

          #{__MODULE__}.broadcast_#{unquote(plural)}_change(#{unquote(singular)}.id, prefix: "live", tenant: post.merchant.slug)

      You have to change your listener signature:

          def handle_info(:changed, {:#{unquote(plural)}, key, _options}), do: # ...

      NOTE: The following subscription will also pick up the above broadcast, but obviously won't have the options:

          #{__MODULE__}.subscribe_to_#{unquote(singular)}(#{unquote(singular)}.id)
      """
      @spec unquote(:"broadcast_#{plural}_change")(
              atom() | integer() | String.t(),
              Keyword.t() | nil
            ) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_change")(key, options \\ []) do
        do_broadcast_plural_event(
          unquote(pubsub),
          :changed,
          key,
          unquote(plural),
          unquote(singular),
          options
        )
      end

      @doc """
      Broadcasts an dynamic event to any listeners with a dynamic payload. The event name is whatever you decide and
      the payload is `{:#{unquote(singular)}, {id, value}}` or `{:#{unquote(singular)}, {id, value}, options}`
      (see below).

      For example lets say you subscribe to all #{unquote(singular)} broadcasts with:

          #{__MODULE__}.subscribe_to_#{unquote(plural)}()

      You can then define the listener:

          def handle_info(:published, {:#{unquote(plural)}, {id, message}}), do: # ...

      And broadcast via:

        #{__MODULE__}.broadcast_#{unquote(plural)}_event(:published, #{unquote(singular)}.id, message)

      However if you want to pub/sub to a specific record:

          #{__MODULE__}.subscribe_to_#{unquote(singular)}(#{unquote(singular)}.id)

      The same listener will work. However if you want to narrow further you can pass a
      `options` keyword to the subscribe:

          #{__MODULE__}.subscribe_to_#{unquote(plural)}(prefix: "live", tenant: :johnny_tackle_shop)

      And to the broadcast:

          #{__MODULE__}.broadcast_#{unquote(plural)}_event(:published, #{unquote(singular)}.id, message, prefix: "live", tenant: post.merchant.slug)

      You have to change your listener signature:

          def handle_info(:published, {:#{unquote(plural)}, {id, message}, options}), do: # ...

      NOTE: The following subscription will also pick up the above broadcast, but obviously won't have the options:

          #{__MODULE__}.subscribe_to_#{unquote(singular)}(#{unquote(singular)}.id)
      """
      @spec unquote(:"broadcast_#{plural}_event")(
              atom() | integer() | String.t(),
              atom() | String.t(),
              Keyword.t() | nil
            ) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_event")(event, key, options \\ []) do
        do_broadcast_plural_event(
          unquote(pubsub),
          event,
          key,
          unquote(plural),
          unquote(singular),
          options
        )
      end

      defp do_broadcast_plural_event(pubsub, event, key, plural, singular, options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.broadcast(
            pubsub,
            Base.encode64(:erlang.term_to_binary({__MODULE__, singular, key, options})),
            {event, {singular, key, options}}
          )

          Phoenix.PubSub.broadcast(
            pubsub,
            Base.encode64(:erlang.term_to_binary({__MODULE__, plural, options})),
            {event, {singular, key}}
          )
        end

        Phoenix.PubSub.broadcast(
          pubsub,
          Base.encode64(:erlang.term_to_binary({__MODULE__, singular, key})),
          {event, {singular, key}}
        )

        Phoenix.PubSub.broadcast(
          pubsub,
          Base.encode64(:erlang.term_to_binary({__MODULE__, plural})),
          {event, {singular, key}}
        )
      end
    end
  end
end
