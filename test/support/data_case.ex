defmodule EctoInterface.DataCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using _opts do
    quote do
      import Ecto
      import Ecto.Query
      import EctoInterface.Factory
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoInterface.TestRepo)
    # on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(EctoInterface.TestRepo) end)
  end
end
