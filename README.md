# EctoInterface

Creates a common set of interface APIs for ecto-based models. By including this functionality you can get a lot of free functionality, including (but not limited to):

- `list_accounts/0` returns all records for a schema
- `count_accounts/0` returns the total nuber of records
- `get_account/1` returns a singular record by it's primary key
- `random_account/0` returns a random record for a schema
- `delete_account/1` deletes a record from the database

and many more.

All you need to do is `use(EctoInterface)` on your context modules:

```elixir
defmodule Core.Users do
  use EctoInterface,
  source: Account,
  plural: :accounts,
  singular: :account
end
```

The first argument is the ecto Schema module, the second is the plural name for the record, and finally the singular.

Additionally if you have `slugy` installed you can use:

```elixir
defmodule Core.Users do
  use EctoInterface,
    source: Account,
    plural: :accounts,
    singular: :account,
    slug: :username
end
```

which gives `Core.Users.get_account_by_slug("kurtis-rainbolt-greene")` (the slug is slugified on query so it doesn't need to be in slug form).

Also, we have a simple interface for tags:

```elixir
defmodule Core.Users do
  use EctoInterface,
    source: Account,
    plural: :accounts,
    singular: :account,
    tagged: :tags
end
```

For useful functions like `Core.Users.list_accounts_with_tags(["friendly", "sporty])`.

Another interface is the `PubSub` interface:

```elixir
defmodule Core.Users do
  use EctoInterface,
    source: Account,
    plural: :accounts,
    singular: :account,
    pubsub: true
end
```

For useful functions like `Core.Users.broadcast_account_change(account)` and `Core.Users.subscribe_to_accounts()`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_interface` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_interface, "~> ..."}
  ]
end
```

And finally in your `config/config.exs`:

```elixir
config :ecto_interface, default_repo: Core.Repo, default_pubsub: Core.PubSub
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ecto_interface>.
