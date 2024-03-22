defmodule Ecto.Integration.SetupMigration do
  use Ecto.Migration

  def change do
    create table(:samples) do
      add(:name, :text)
      add(:age, :integer)
      timestamps()
    end
  end
end
