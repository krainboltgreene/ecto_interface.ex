defmodule EctoInterfaceContext.Address do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:city, :string, autogenerate: false}

  schema "addresses" do
    belongs_to(:customer, EctoInterfaceContext.Customer)
  end
end
