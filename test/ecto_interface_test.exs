defmodule EctoInterfaceTest do
  use ExUnit.Case
  use Ecto.Integration.Case
  doctest EctoInterface
  import Ecto.Query

  alias Ecto.Integration.TestRepo

  defmodule Sample do
    use Ecto.Schema

    schema "samples" do
      field(:name, :string)
      timestamps()
    end

    def changeset(record, changes) do
      record
      |> Ecto.Changeset.cast(changes, [:name])
    end

    def other_changeset(record, changes) do
      record
      |> Ecto.Changeset.cast(changes, [:name])
    end
  end

  defmodule SampleShorthandContext do
    use(EctoInterface, [Sample, :samples, :sample])
  end

  test("random_sample/0") do
    a = TestRepo.insert!(%Sample{name: "a"})
    b = TestRepo.insert!(%Sample{name: "b"})
    c = TestRepo.insert!(%Sample{name: "c"})
    assert([a, b, c] |> Enum.member?(SampleShorthandContext.random_sample()))
  end

  test("list_samples/0") do
    a = TestRepo.insert!(%Sample{name: "a"})
    b = TestRepo.insert!(%Sample{name: "b"})
    c = TestRepo.insert!(%Sample{name: "c"})
    assert(SampleShorthandContext.list_samples() == [a, b, c])
  end

  test("list_samples/1") do
    a = TestRepo.insert!(%Sample{name: "a"})
    _b = TestRepo.insert!(%Sample{name: "b"})
    _c = TestRepo.insert!(%Sample{name: "c"})

    assert(
      SampleShorthandContext.list_samples(fn schema -> from(schema, where: [name: "a"]) end) == [
        a
      ]
    )
  end

  test("count_samples/0") do
    _a = TestRepo.insert!(%Sample{name: "a"})
    _b = TestRepo.insert!(%Sample{name: "b"})
    _c = TestRepo.insert!(%Sample{name: "c"})
    assert(SampleShorthandContext.count_samples() == 3)
  end

  test("count_samples/1") do
    _a = TestRepo.insert!(%Sample{name: "a"})
    _b = TestRepo.insert!(%Sample{name: "b"})
    _c = TestRepo.insert!(%Sample{name: "c"})

    assert(
      SampleShorthandContext.count_samples(fn schema -> from(schema, where: [name: "a"]) end) == 1
    )
  end
end
