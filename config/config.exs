# General application configuration
import Config

config :ecto_interface,
  default_repo: EctoInterface.TestRepo,
  ecto_repos: [EctoInterface.TestRepo]

config :ecto_interface, EctoInterface.TestRepo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "postgres",
  password: "postgres",
  database: "paginator_test"
