defmodule EctoInterfaceContext do
  import Ecto.Query

  use(EctoInterface,
    source: Customer,
    plural: :customers,
    singular: :customer
  )

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
end
