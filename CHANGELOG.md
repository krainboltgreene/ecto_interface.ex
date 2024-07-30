# Changelog

## 3.0.0

- [breaking] [feature] Now when you pass preloads to `create` or `update` it will then preload after the insert/update as well.

## 2.3.1

- [bug] Both `change_#{singular}` and `new_#{singular}` were incorrectly still enforcing a `map()` type for the value.

## 2.3.0

- [feature] Prior understandings of Ecto's "changeset" functions were that they took a record and a mapping of attributes. My understanding has grown since then, for example compounding changesets makes sense and also no second (or multiple) arguments. I've at least removed the restriction of it being a map for the second arugment. You can now do: `Core.Users.create_account(:pending)` and it should be compatible.

## 2.2.1

- [fix] Relax the requirements of the optional postgrex version

## 2.2.0

- [feature] Improved type annotation for the create functions
- [fix] Now you can pass repository options to `paginate_` functions whereas before they were swallowed

## 2.1.0

- [feature] Now includes pagination functionality via `paginated_*/*`, much like `stream_*`. This is incorporated into the library by copying the Paginator code. I wanted to just use the library as normal but it's kinda outdated.
- [breaking fix] `new_*/1` and `new_*/2` had conflicts, now there is only `new_customer(record, attributes, changeset_function)` and `new_customer(attributes, changeset_function)`
- [breaking fix] `stream_*_by/2` wasn't actually calling `stream/0`.
- [fix] Multiple specs are now correctly showing the options variant

## 2.0.0

- [feature] All functions that can now support the `options` optional argument, which gets passed to `Repo.all/*`, `Repo.one/*`, `Repo.get/*`, `Repo.stream/*`, `Repo.insert/*`, `Repo.update/*`, and `Repo.delete/*`. This is useful for: Timeouts, prefixes, and more.
- [breaking] All `Read`, `Tagged` and `Slug` functions that previously took `subquery` are now named `_by/`, for example `Core.Users.list_accounts(&where(&1, name: "Kurtis Rainbolt-Greene"))` now becomes `Core.Users.list_accounts_by(&where(&1, name: "Kurtis Rainbolt-Greene"))`.
- [breaking] All `Write` functions that previously took custom changeset functions are now named `_by/`, for example `Core.Users.create_account(&Core.Users.Account.update_name_changeset/2, %{name: "Kurtis Rainbolt-Greene"})` now becomes `Core.Users.create_account_by(%{name: "Kurtis Rainbolt-Greene"}, &Core.Users.Account.update_name_changeset/2)`.
- [breaking] I've removed the `get_*_by(Keyword.t())` function because it doesn't make sense given the `subquery` enabled read function.
- [breaking] I've moved `EctoInterface.Read.PubSub` to `EctoInterface.PubSub` since it has both read/write functions.

## 1.3.0

- [feature] New `EctoInterface.Read.PubSub` module for supercharging your contexts with pubsub capabilities. Requires `default_pubsub` as a configuration.
- [feature] New `stream_*/0` and `stream_*/1` functions that return an `Stream` from `Ecto`. Must be executed inside a transaction like all ecto streaming.
- [feature] Added the ability to define which changeset is used in `new_*/*`, `change_*/*`, `update_*/*`, and `create_*/*`.
- Increased test robustness.

## 1.2.0

- [feature] `get_*/1` take a `id` (a primary key) _or_ a `subquery`, but that forces the query version to do the `limit`, `where`, and `one`, now we have two: `get_*/1` that takes an `id` _or_ a query and `get_*/2` which takes an `id` and `subquery` where we do the expected work.

## 1.1.1

- [bugfix] Accidentally was passing the changeset to the preload function, added some tests as well

## 1.1.0

- [feature] Now when create/updating a resource you can pass in a `preload: []` keyword like for `Repo.preload/1`

## 1.0.0

- First release
