Application.ensure_all_started(:postgrex)
Application.ensure_all_started(:ecto)

Code.require_file("support/setup_migration.exs", __DIR__)

# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.Postgres.storage_down(EctoInterface.TestRepo.config())
:ok = Ecto.Adapters.Postgres.storage_up(EctoInterface.TestRepo.config())

# {:ok, _} =
#   Ecto.Adapters.SQLite3.ensure_all_started(EctoInterface.TestRepo.config(), :temporary)

{:ok, pid} = EctoInterface.TestRepo.start_link()

:ok = Ecto.Migrator.up(EctoInterface.TestRepo, 0, EctoInterface.SetupMigration, log: false)

Ecto.Adapters.SQL.Sandbox.mode(EctoInterface.TestRepo, {:shared, pid})

ExUnit.start()
