defmodule EctoInterface.TestRepo do
  use Ecto.Repo,
    otp_app: :ecto_interface,
    adapter: Ecto.Adapters.Postgres

  use EctoInterface.Paginator
end
