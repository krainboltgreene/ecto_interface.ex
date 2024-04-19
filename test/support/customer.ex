defmodule EctoInterface.Customer do
  use Ecto.Schema

  import Ecto.Query

  schema "customers" do
    field(:name, :string)
    field(:age, :integer)
    field(:active, :boolean)
    field(:internal_uuid, :binary_id)
    field(:rank_value, :float, virtual: true)

    has_many(:payments, EctoInterface.Payment)
    has_one(:address, EctoInterface.Address)

    timestamps()
  end

  def active(query) do
    query |> where([c], c.active == true)
  end

  def changeset(record, changes) do
    record
    |> Ecto.Changeset.cast(changes, [:name, :internal_uuid])
  end

  def other_changeset(record, changes) do
    record
    |> Ecto.Changeset.cast(changes, [:name, :age, :internal_uuid])
  end
end
