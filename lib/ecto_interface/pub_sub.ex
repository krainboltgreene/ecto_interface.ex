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

    quote(location: :keep) do
      @doc """
      Subscribes to any messages broadcast to the #{__MODULE__}/#{unquote(singular)} channel.
      """
      @spec unquote(:"subscribe_to_#{plural}")(Keyword.t() | nil) :: :ok
      def unquote(:"subscribe_to_#{plural}")(options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.subscribe(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}/#{inspect(options)}"
          )
        else
          Phoenix.PubSub.subscribe(unquote(pubsub), "#{__MODULE__}/#{unquote(singular)}")
        end
      end

      @doc """
      Subscribes to any messages broadcast to the #{__MODULE__}/#{unquote(singular)}/id:`id` channel.
      """
      @spec unquote(:"subscribe_to_#{singular}")(
              atom() | integer() | String.t(),
              Keyword.t() | nil
            ) :: :ok
      def unquote(:"subscribe_to_#{singular}")(key, options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.subscribe(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}:#{key}/#{inspect(options)}"
          )
        else
          Phoenix.PubSub.subscribe(unquote(pubsub), "#{__MODULE__}/#{unquote(singular)}:#{key}")
        end
      end

      @doc """
      Broadcasts an insert of the specified `record` to the topics:

        - #{__MODULE__}/#{unquote(singular)}
        - #{__MODULE__}/#{unquote(singular)}/{{options}}
        - #{__MODULE__}/#{unquote(singular)}:{{key}}

      The event name is `:inserted` and the payload is `{:#{unquote(singular)}, id}` or `{:#{unquote(singular)}, id, options}` (see below).

      For example lets say you subscribe with:

          MyApp.Transactions.subscribe_to_charges()

      You can then define the listener:

          def handle_info(:inserted, {:charges, key}), do: # ...

      And broadcast via:

        MyApp.Transactions.broadcast_charges_insert(charge)

      However if you want to pub/sub to a specific record:

          MyApp.Transactions.subscribe_to_charge(charge.id)

      The same listener will work.

      However if you want to narrow further you can pass a `options` keyword to the subscribe:

          MyApp.Transactions.subscribe_to_charges(prefix: "live", tenant: :johnny_tackle_shop)

      And to the broadcast:

          MyApp.Transactions.broadcast_charges_insert(charge, prefix: "live", tenant: charge.merchant.slug)

      You have to change your listener signature:

          def handle_info(:inserted, {:charges, key, _options}), do: # ...

      NOTE: The following subscription will also pick up the above broadcast, but obviously won't have the options:

          MyApp.Transactions.subscribe_to_charge(charge.id)
      """
      @spec unquote(:"broadcast_#{plural}_insert")(atom() | integer() | String.t(), atom()) ::
              :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_insert")(key, options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}/#{inspect(options)}",
            {:inserted, {unquote(singular), key, options}}
          )

          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}:#{key}",
            {:inserted, {unquote(singular), key, options}}
          )
        else
          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}",
            {:inserted, {unquote(singular), key}}
          )

          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}:#{key}",
            {:inserted, {unquote(singular), key}}
          )
        end
      end

      @doc """
      Broadcasts a change of the specified `record` to the topics:

        - #{__MODULE__}/#{unquote(singular)}
        - #{__MODULE__}/#{unquote(singular)}/{{options}}
        - #{__MODULE__}/#{unquote(singular)}:{{key}}

      The event name is `:changed` and the payload is `{:#{unquote(singular)}, id}` or `{:#{unquote(singular)}, id, options}` (see below).

      For example lets say you subscribe with:

          MyApp.Transactions.subscribe_to_charges()

      You can then define the listener:

          def handle_info(:changed, {:charges, key}), do: # ...

      And broadcast via:

        MyApp.Transactions.broadcast_charges_change(charge)

      However if you want to pub/sub to a specific record:

          MyApp.Transactions.subscribe_to_charge(charge.id)

      The same listener will work.

      However if you want to narrow further you can pass a `options` keyword to the subscribe:

          MyApp.Transactions.subscribe_to_charges(prefix: "live", tenant: :johnny_tackle_shop)

      And to the broadcast:

          MyApp.Transactions.broadcast_charges_change(charge, prefix: "live", tenant: charge.merchant.slug)

      You have to change your listener signature:

          def handle_info(:changed, {:charges, key, _options}), do: # ...

      NOTE: The following subscription will also pick up the above broadcast, but obviously won't have the options:

          MyApp.Transactions.subscribe_to_charge(charge.id)
      """
      @spec unquote(:"broadcast_#{plural}_change")(
              atom() | integer() | String.t(),
              Keyword.t() | nil
            ) :: :ok | {:error, term()}
      def unquote(:"broadcast_#{plural}_change")(key, options \\ []) do
        if Keyword.keyword?(options) && Enum.any?(options) do
          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}/#{inspect(options)}",
            {:changed, {unquote(singular), key, options}}
          )

          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}:#{key}",
            {:changed, {unquote(singular), key, options}}
          )
        else
          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}",
            {:changed, {unquote(singular), key}}
          )

          Phoenix.PubSub.broadcast(
            unquote(pubsub),
            "#{__MODULE__}/#{unquote(singular)}:#{key}",
            {:changed, {unquote(singular), key}}
          )
        end
      end
    end
  end
end
