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
      field(:age, :integer)
      timestamps()
    end

    def changeset(record, changes) do
      record
      |> Ecto.Changeset.cast(changes, [:name])
    end

    def other_changeset(record, changes) do
      record
      |> Ecto.Changeset.cast(changes, [:name, :age])
    end
  end

  defmodule SampleShorthandContext do
    use(EctoInterface, [Sample, :samples, :sample])
  end

  test("get_sample/1 with id") do
    TestRepo.insert!(%Sample{name: "a"})
    b = TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})
    assert(b == SampleShorthandContext.get_sample(b.id))
  end

  test("get_sample_by/2") do
    TestRepo.insert!(%Sample{name: "a"})
    b = TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})

    assert(
      b ==
        SampleShorthandContext.get_sample_by(b.id, fn query ->
          where(query, [s], s.name == "b")
        end)
    )
  end

  test("get_sample_by/2 with no match") do
    TestRepo.insert!(%Sample{name: "a"})
    b = TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})

    assert(
      nil ==
        SampleShorthandContext.get_sample_by(b.id, fn query ->
          where(query, [s], s.name == "c")
        end)
    )
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

  test("list_samples_by/1") do
    a = TestRepo.insert!(%Sample{name: "a"})
    TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})

    assert(
      SampleShorthandContext.list_samples_by(fn schema -> from(schema, where: [name: "a"]) end) ==
        [
          a
        ]
    )
  end

  test("stream_samples/0") do
    TestRepo.insert!(%Sample{name: "a"})
    TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})

    query =
      SampleShorthandContext.stream_samples()
      |> Stream.map(&Map.get(&1, :name))

    TestRepo.transaction(fn ->
      assert(
        Enum.to_list(query) == [
          "a",
          "b",
          "c"
        ]
      )
    end)
  end

  test("stream_samples_by/1") do
    TestRepo.insert!(%Sample{name: "a"})
    TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})

    query =
      SampleShorthandContext.stream_samples_by(fn query -> where(query, [x], x.name != ^"a") end)
      |> Stream.map(&Map.get(&1, :name))

    TestRepo.transaction(fn ->
      assert(
        Enum.to_list(query) == [
          "b",
          "c"
        ]
      )
    end)
  end

  test("count_samples/0") do
    TestRepo.insert!(%Sample{name: "a"})
    TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})
    assert(SampleShorthandContext.count_samples() == 3)
  end

  test("count_samples_by/1") do
    TestRepo.insert!(%Sample{name: "a"})
    TestRepo.insert!(%Sample{name: "b"})
    TestRepo.insert!(%Sample{name: "c"})

    assert(
      SampleShorthandContext.count_samples_by(fn schema -> from(schema, where: [name: "a"]) end) ==
        1
    )
  end

  test("create_sample/1") do
    {:ok, a} =
      SampleShorthandContext.create_sample(%{name: "a", age: 2})

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "a")
    assert(SampleShorthandContext.random_sample().age == nil)
  end

  test("create_sample_by/2") do
    {:ok, a} =
      SampleShorthandContext.create_sample_by(%{name: "a", age: 2}, &Sample.other_changeset/2)

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "a")
    assert(SampleShorthandContext.random_sample().age == 2)
  end

  test("update_sample/2") do
    a = TestRepo.insert!(%Sample{name: "a"})

    {:ok, a} =
      SampleShorthandContext.update_sample(a, %{name: "b", age: 2})

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "b")
    assert(SampleShorthandContext.random_sample().age == nil)
  end

  test("update_sample_by/3") do
    a = TestRepo.insert!(%Sample{name: "a"})

    {:ok, a} =
      SampleShorthandContext.update_sample_by(a, %{name: "b", age: 2}, &Sample.other_changeset/2)

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "b")
    assert(SampleShorthandContext.random_sample().age == 2)
  end

  test("create_sample!/1") do
    a = SampleShorthandContext.create_sample!(%{name: "a", age: 2})

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "a")
    assert(SampleShorthandContext.random_sample().age == nil)
  end

  test("create_sample_by!/2") do
    a = SampleShorthandContext.create_sample_by!(%{name: "a", age: 2}, &Sample.other_changeset/2)

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "a")
    assert(SampleShorthandContext.random_sample().age == 2)
  end

  test("update_sample!/2") do
    a = TestRepo.insert!(%Sample{name: "a"})

    a = SampleShorthandContext.update_sample!(a, %{name: "b", age: 2})

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "b")
    assert(SampleShorthandContext.random_sample().age == nil)
  end

  test("update_sample_by!/3") do
    a = TestRepo.insert!(%Sample{name: "a"})

    a =
      SampleShorthandContext.update_sample_by!(a, %{name: "b", age: 2}, &Sample.other_changeset/2)

    assert(SampleShorthandContext.random_sample() == a)
    assert(SampleShorthandContext.random_sample().name == "b")
    assert(SampleShorthandContext.random_sample().age == 2)
  end
end
