# Changelog

## 1.3.0

- [feature] New `EctoInterface.Read.PubSub` module for supercharging your contexts with pubsub capabilities. Requires `default_pubsub` as a configuration.
- [feature] New `stream_*/0` and `stream_*/1` functions that return an Stream from Ecto. Must be executed inside a transaction like normal.
- [feature] Added the ability to define which changeset is used in `new_*/*`, `change_*/*`, `update_*/*`, and `create_*/*`.
- Increased test robustness.

## 1.2.0

- [feature] `get_singular/1` take a `id` (a primary key) _or_ a `query`, but that forces the query version to do the `limit`, `where`, and `one`, now we have two: `get_singular/1` that takes an `id` _or_ a query and `get_singular/2` which takes an `id` and `query` where we do the expected work.

## 1.1.1

- [bugfix] Accidentally was passing the changeset to the preload function, added some tests as well

## 1.1.0

- [feature] Now when create/updating a resource you can pass in a `preload: []` keyword like for `MyApp.Repo.preload/1`

## 1.0.0

- First release
