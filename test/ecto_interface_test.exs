defmodule EctoInterfaceContext do
  use(EctoInterface, source: Customer, plural: :customers, singular: :customer)

  use(EctoInterface,
    source: Customer,
    plural: :customersa,
    singular: :customera,
    repo: EctoInterface.TestRepo
  )

  use(EctoInterface,
    source: Address,
    plural: :addresses,
    singular: :address
  )

  use(EctoInterface,
    source: Customer,
    plural: :customersb,
    singular: :customerb,
    pubsub: Core.PubSub
  )

  use(EctoInterface,
    source: Customer,
    plural: :customersc,
    singular: :customerc,
    tagged: :tags
  )

  use(EctoInterface,
    source: Customer,
    plural: :customersd,
    singular: :customerd,
    slug: :slurg
  )
end

defmodule EctoInterfaceTest do
  use ExUnit.Case
  use EctoInterface.DataCase

  doctest EctoInterface

  import Ecto.Query

  test("get_customer/1 with id") do
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(b == EctoInterfaceContext.get_customer(b.id))
  end

  test("get_customer_by/2") do
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      b ==
        EctoInterfaceContext.get_customer_by(b.id, fn query ->
          where(query, [s], s.name == "b")
        end)
    )
  end

  test("get_customer_by/2 with no match") do
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      nil ==
        EctoInterfaceContext.get_customer_by(b.id, fn query ->
          where(query, [s], s.name == "c")
        end)
    )
  end

  test("random_customer/0") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    c =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "c",
        internal_uuid: Ecto.UUID.generate()
      })

    assert([a, b, c] |> Enum.member?(EctoInterfaceContext.random_customer()))
  end

  test("list_customers/0") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    b =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "b",
        internal_uuid: Ecto.UUID.generate()
      })

    c =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "c",
        internal_uuid: Ecto.UUID.generate()
      })

    assert(EctoInterfaceContext.list_customers() == [a, b, c])
  end

  test("list_customers_by/1") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      EctoInterfaceContext.list_customers_by(fn schema -> from(schema, where: [name: "a"]) end) ==
        [
          a
        ]
    )
  end

  test("stream_customers/0") do
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    query =
      EctoInterfaceContext.stream_customers()
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
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    query =
      EctoInterfaceContext.stream_customers_by(fn query ->
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
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(EctoInterfaceContext.count_customers() == 3)
  end

  test("count_customers_by/1") do
    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "a",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "b",
      internal_uuid: Ecto.UUID.generate()
    })

    EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
      name: "c",
      internal_uuid: Ecto.UUID.generate()
    })

    assert(
      EctoInterfaceContext.count_customers_by(fn schema -> from(schema, where: [name: "a"]) end) ==
        1
    )
  end

  test("create_customer/1") do
    {:ok, a} =
      EctoInterfaceContext.create_customer(%{
        name: "a",
        age: 2,
        internal_uuid: Ecto.UUID.generate()
      })

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "a")
    assert(EctoInterfaceContext.random_customer().age == nil)
  end

  test("create_customer_by/2") do
    {:ok, a} =
      EctoInterfaceContext.create_customer_by(
        %{name: "a", age: 2, internal_uuid: Ecto.UUID.generate()},
        &EctoInterfaceContext.Customer.other_changeset/2
      )

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "a")
    assert(EctoInterfaceContext.random_customer().age == 2)
  end

  test("update_customer/2") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    {:ok, a} =
      EctoInterfaceContext.update_customer(a, %{name: "b", age: 2})

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "b")
    assert(EctoInterfaceContext.random_customer().age == nil)
  end

  test("update_customer_by/3") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    {:ok, a} =
      EctoInterfaceContext.update_customer_by(
        a,
        %{name: "b", age: 2},
        &EctoInterfaceContext.Customer.other_changeset/2
      )

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "b")
    assert(EctoInterfaceContext.random_customer().age == 2)
  end

  test("create_customer!/1") do
    a =
      EctoInterfaceContext.create_customer!(%{
        name: "a",
        age: 2,
        internal_uuid: Ecto.UUID.generate()
      })

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "a")
    assert(EctoInterfaceContext.random_customer().age == nil)
  end

  test("create_customer_by!/2") do
    a =
      EctoInterfaceContext.create_customer_by!(
        %{name: "a", age: 2, internal_uuid: Ecto.UUID.generate()},
        &EctoInterfaceContext.Customer.other_changeset/2
      )

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "a")
    assert(EctoInterfaceContext.random_customer().age == 2)
  end

  test("update_customer!/2") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    a = EctoInterfaceContext.update_customer!(a, %{name: "b", age: 2})

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "b")
    assert(EctoInterfaceContext.random_customer().age == nil)
  end

  test("update_customer_by!/3") do
    a =
      EctoInterface.TestRepo.insert!(%EctoInterfaceContext.Customer{
        name: "a",
        internal_uuid: Ecto.UUID.generate()
      })

    a =
      EctoInterfaceContext.update_customer_by!(
        a,
        %{name: "b", age: 2},
        &EctoInterfaceContext.Customer.other_changeset/2
      )

    assert(EctoInterfaceContext.random_customer() == a)
    assert(EctoInterfaceContext.random_customer().name == "b")
    assert(EctoInterfaceContext.random_customer().age == 2)
  end
end
