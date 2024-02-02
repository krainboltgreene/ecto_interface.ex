# Changelog

## 1.2.0

  - [feature] `get_singular/1` take a `id` (a primary key) *or* a `query`, but that forces the query version to do the `limit`, `where`, and `one`, now we have two: `get_singular/1` that takes an `id` *or* a query and `get_singular/2` which takes an `id` and `query` where we do the expected work.

## 1.1.1

  - [bugfix] Accidentally was passing the changeset to the preload function, added some tests as well

## 1.1.0

  - [feature] Now when create/updating a resource you can pass in a `preload: []` keyword like for `MyApp.Repo.preload/1`

## 1.0.0

  - First release
