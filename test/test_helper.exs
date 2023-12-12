alias Ecto.Integration.TestRepo

Application.put_env(:ecto, TestRepo,
  database: "tmp/test.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox
)

Application.put_env(:ecto_interface, :default_repo, TestRepo)

defmodule Ecto.Integration.TestRepo do
  use Ecto.Repo, otp_app: :ecto, adapter: Ecto.Adapters.SQLite3

  def log(_cmd), do: nil
end

defmodule Ecto.Integration.Case do
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(TestRepo)
    # on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(TestRepo) end)
  end
end

{:ok, _} = Ecto.Adapters.SQLite3.ensure_all_started(TestRepo.config(), :temporary)

# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.SQLite3.storage_down(TestRepo.config())
:ok = Ecto.Adapters.SQLite3.storage_up(TestRepo.config())

{:ok, pid} = TestRepo.start_link()

Code.require_file("ecto_migrations.exs", __DIR__)

:ok = Ecto.Migrator.up(TestRepo, 0, Ecto.Integration.SetupMigration, log: false)

Ecto.Adapters.SQL.Sandbox.mode(TestRepo, {:shared, pid})
ExUnit.start()
