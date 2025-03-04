defmodule EctoInterfaceTest do
  use ExUnit.Case
  use EctoInterface.DataCase

  doctest EctoInterface

  import Ecto.Query

  defmodule SampleShorthandContext do
    use(EctoInterface, source: EctoInterface.Customer, plural: :customers, singular: :customer)

    use(EctoInterface,
      source: EctoInterface.Customer,
      plural: :customersa,
      singular: :customera,
      repo: EctoInterface.TestRepo
    )

    use(EctoInterface,
      source: EctoInterface.Address,
      plural: :addresses,
      singular: :address
    )

    use(EctoInterface,
      source: EctoInterface.Customer,
      plural: :customersb,
      singular: :customerb,
      pubsub: Core.PubSub
    )

    use(EctoInterface,
      source: EctoInterface.Customer,
      plural: :customersc,
      singular: :customerc,
      tagged: :tags
    )

    use(EctoInterface,
      source: EctoInterface.Customer,
      plural: :customersd,
      singular: :customerd,
      slug: :slurg
    )
  end

  test("get_customer/1 with id") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(b == SampleShorthandContext.get_customer(b.id))
  end

  test("get_customer_by/2") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      b ==
        SampleShorthandContext.get_customer_by(b.id, fn query ->
          where(query, [s], s.name == "b")
        end)
    )
  end

  test("get_customer_by/2 with no match") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      nil ==
        SampleShorthandContext.get_customer_by(b.id, fn query ->
          where(query, [s], s.name == "c")
        end)
    )
  end

  test("random_customer/0") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    c =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "c",
        internal_uuid: Ecto.UUID.generate()
      })

    assert([a, b, c] |> Enum.member?(SampleShorthandContext.random_customer()))
  end

  test("list_customers/0") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    c =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "c",
        internal_uuid: Ecto.UUID.generate()
      })

    assert(SampleShorthandContext.list_customers() == [a, b, c])
  end

  test("list_customers_by/1") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      SampleShorthandContext.list_customers_by(fn schema -> from(schema, where: [name: "a"]) end) ==
        [
          a
        ]
    )
  end

  test("stream_customers/0") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    query =
      SampleShorthandContext.stream_customers()
      |> Stream.map(&Map.get(&1, :name))

    EctoInterface.TestRepo.transaction(fn ->
      assert(
        Enum.to_list(query) == [
          "a",
          "b",
          "c"
        ]
      )
    end)
  end

  test("stream_customers_by/1") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    query =
      SampleShorthandContext.stream_customers_by(fn query ->
        where(query, [x], x.name != ^"a")
      end)
      |> Stream.map(&Map.get(&1, :name))

    EctoInterface.TestRepo.transaction(fn ->
      assert(
        Enum.to_list(query) == [
          "b",
          "c"
        ]
      )
    end)
  end

  test("count_customers/0") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(SampleShorthandContext.count_customers() == 3)
  end

  test("count_customers_by/1") do
    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      SampleShorthandContext.count_customers_by(fn schema -> from(schema, where: [name: "a"]) end) ==
        1
    )
  end

  test("create_customer/1") do
    {:ok, a} =
      SampleShorthandContext.create_customer(%{
        name: "a",
        age: 2,
        internal_uuid: Ecto.UUID.generate()
      })

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "a")
    assert(SampleShorthandContext.random_customer().age == nil)
  end

  test("create_customer_by/2") do
    {:ok, a} =
      SampleShorthandContext.create_customer_by(
        %{name: "a", age: 2, internal_uuid: Ecto.UUID.generate()},
        &EctoInterface.Customer.other_changeset/2
      )

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "a")
    assert(SampleShorthandContext.random_customer().age == 2)
  end

  test("update_customer/2") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    {:ok, a} =
      SampleShorthandContext.update_customer(a, %{name: "b", age: 2})

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "b")
    assert(SampleShorthandContext.random_customer().age == nil)
  end

  test("update_customer_by/3") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    {:ok, a} =
      SampleShorthandContext.update_customer_by(
        a,
        %{name: "b", age: 2},
        &EctoInterface.Customer.other_changeset/2
      )

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "b")
    assert(SampleShorthandContext.random_customer().age == 2)
  end

  test("create_customer!/1") do
    a =
      SampleShorthandContext.create_customer!(%{
        name: "a",
        age: 2,
        internal_uuid: Ecto.UUID.generate()
      })

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "a")
    assert(SampleShorthandContext.random_customer().age == nil)
  end

  test("create_customer_by!/2") do
    a =
      SampleShorthandContext.create_customer_by!(
        %{name: "a", age: 2, internal_uuid: Ecto.UUID.generate()},
        &EctoInterface.Customer.other_changeset/2
      )

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "a")
    assert(SampleShorthandContext.random_customer().age == 2)
  end

  test("update_customer!/2") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    a = SampleShorthandContext.update_customer!(a, %{name: "b", age: 2})

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "b")
    assert(SampleShorthandContext.random_customer().age == nil)
  end

  test("update_customer_by!/3") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterface.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    a =
      SampleShorthandContext.update_customer_by!(
        a,
        %{name: "b", age: 2},
        &EctoInterface.Customer.other_changeset/2
      )

    assert(SampleShorthandContext.random_customer() == a)
    assert(SampleShorthandContext.random_customer().name == "b")
    assert(SampleShorthandContext.random_customer().age == 2)
  end
end
