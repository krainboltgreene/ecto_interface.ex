defmodule EctoInterface.PaginatorTest do
  use EctoInterface.DataCase

  import Ecto.Query

  alias Calendar.DateTime, as: DT

  setup :create_customers_and_payments

  test "paginates forward", %{
    payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
  } do
    opts = [cursor_fields: [:charged_at, :id], sort_direction: :asc, limit: 4]

    page = payments_by_charged_at() |> EctoInterface.TestRepo.paginate(opts)
    assert to_ids(page.entries) == to_ids([p5, p4, p1, p6])
    assert page.metadata.after == encode_cursor(%{charged_at: p6.charged_at, id: p6.id})

    page =
      payments_by_charged_at()
      |> EctoInterface.TestRepo.paginate(opts ++ [after: page.metadata.after])

    assert to_ids(page.entries) == to_ids([p7, p3, p10, p2])
    assert page.metadata.after == encode_cursor(%{charged_at: p2.charged_at, id: p2.id})

    page =
      payments_by_charged_at()
      |> EctoInterface.TestRepo.paginate(opts ++ [after: page.metadata.after])

    assert to_ids(page.entries) == to_ids([p12, p8, p9, p11])
    assert page.metadata.after == nil
  end

  test "paginates forward with legacy cursor", %{
    payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
  } do
    opts = [cursor_fields: [:charged_at, :id], sort_direction: :asc, limit: 4]

    page = payments_by_charged_at() |> EctoInterface.TestRepo.paginate(opts)
    assert to_ids(page.entries) == to_ids([p5, p4, p1, p6])

    assert %{charged_at: charged_at, id: id} =
             EctoInterface.Paginator.Cursor.decode(page.metadata.after)

    assert charged_at == p6.charged_at
    assert id == p6.id

    legacy_cursor = encode_legacy_cursor([charged_at, id])

    page =
      payments_by_charged_at() |> EctoInterface.TestRepo.paginate(opts ++ [after: legacy_cursor])

    assert to_ids(page.entries) == to_ids([p7, p3, p10, p2])

    assert %{charged_at: charged_at, id: id} =
             EctoInterface.Paginator.Cursor.decode(page.metadata.after)

    assert charged_at == p2.charged_at
    assert id == p2.id

    legacy_cursor = encode_legacy_cursor([charged_at, id])

    page =
      payments_by_charged_at() |> EctoInterface.TestRepo.paginate(opts ++ [after: legacy_cursor])

    assert to_ids(page.entries) == to_ids([p12, p8, p9, p11])
    assert page.metadata.after == nil
  end

  test "paginates backward", %{
    payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
  } do
    opts = [cursor_fields: [:charged_at, :id], sort_direction: :asc, limit: 4]

    page =
      payments_by_charged_at()
      |> EctoInterface.TestRepo.paginate(
        opts ++ [before: encode_cursor(%{charged_at: p11.charged_at, id: p11.id})]
      )

    assert to_ids(page.entries) == to_ids([p2, p12, p8, p9])
    assert page.metadata.before == encode_cursor(%{charged_at: p2.charged_at, id: p2.id})

    page =
      payments_by_charged_at()
      |> EctoInterface.TestRepo.paginate(opts ++ [before: page.metadata.before])

    assert to_ids(page.entries) == to_ids([p6, p7, p3, p10])
    assert page.metadata.before == encode_cursor(%{charged_at: p6.charged_at, id: p6.id})

    page =
      payments_by_charged_at()
      |> EctoInterface.TestRepo.paginate(opts ++ [before: page.metadata.before])

    assert to_ids(page.entries) == to_ids([p5, p4, p1])
    assert page.metadata.after == encode_cursor(%{charged_at: p1.charged_at, id: p1.id})
    assert page.metadata.before == nil
  end

  test "returns an empty page when there are no results" do
    page =
      payments_by_status("failed")
      |> EctoInterface.TestRepo.paginate(cursor_fields: [:charged_at, :id], limit: 10)

    assert page.entries == []
    assert page.metadata.after == nil
    assert page.metadata.before == nil
  end

  describe "paginate a collection of payments, sorting by charged_at" do
    test "sorts ascending without cursors", %{
      payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :asc,
          limit: 50
        )

      assert to_ids(entries) == to_ids([p5, p4, p1, p6, p7, p3, p10, p2, p12, p8, p9, p11])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 50}
    end

    test "sorts ascending with before cursor", %{
      payments: {p1, p2, p3, _p4, _p5, p6, p7, p8, p9, p10, _p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :asc,
          before: encode_cursor(%{charged_at: p9.charged_at, id: p9.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p1, p6, p7, p3, p10, p2, p12, p8])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{charged_at: p8.charged_at, id: p8.id}),
               before: encode_cursor(%{charged_at: p1.charged_at, id: p1.id}),
               limit: 8
             }
    end

    test "sorts ascending with after cursor", %{
      payments: {_p1, p2, p3, _p4, _p5, _p6, _p7, p8, p9, p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :asc,
          after: encode_cursor(%{charged_at: p3.charged_at, id: p3.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p10, p2, p12, p8, p9, p11])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: nil,
               before: encode_cursor(%{charged_at: p10.charged_at, id: p10.id}),
               limit: 8
             }
    end

    test "sorts ascending with before and after cursor", %{
      payments: {_p1, p2, p3, _p4, _p5, _p6, _p7, p8, _p9, p10, _p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :asc,
          after: encode_cursor(%{charged_at: p3.charged_at, id: p3.id}),
          before: encode_cursor(%{charged_at: p8.charged_at, id: p8.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p10, p2, p12])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{charged_at: p12.charged_at, id: p12.id}),
               before: encode_cursor(%{charged_at: p10.charged_at, id: p10.id}),
               limit: 8
             }
    end

    test "sorts descending without cursors", %{
      payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          limit: 50
        )

      assert to_ids(entries) == to_ids([p11, p9, p8, p12, p2, p10, p3, p7, p6, p1, p4, p5])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 50}
    end

    test "sorts descending with before cursor", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, p9, _p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          before: encode_cursor(%{charged_at: p9.charged_at, id: p9.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p11])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{charged_at: p11.charged_at, id: p11.id}),
               before: nil,
               limit: 8
             }
    end

    test "sorts descending with after cursor", %{
      payments: {p1, p2, p3, _p4, _p5, p6, p7, p8, p9, p10, _p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          after: encode_cursor(%{charged_at: p9.charged_at, id: p9.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p8, p12, p2, p10, p3, p7, p6, p1])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{charged_at: p1.charged_at, id: p1.id}),
               before: encode_cursor(%{charged_at: p8.charged_at, id: p8.id}),
               limit: 8
             }
    end

    test "sorts descending with before and after cursor", %{
      payments: {_p1, p2, p3, _p4, _p5, _p6, _p7, p8, p9, p10, _p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          after: encode_cursor(%{charged_at: p9.charged_at, id: p9.id}),
          before: encode_cursor(%{charged_at: p3.charged_at, id: p3.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p8, p12, p2, p10])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{charged_at: p10.charged_at, id: p10.id}),
               before: encode_cursor(%{charged_at: p8.charged_at, id: p8.id}),
               limit: 8
             }
    end

    test "sorts ascending with before cursor at beginning of collection", %{
      payments: {_p1, _p2, _p3, _p4, p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :asc,
          before: encode_cursor(%{charged_at: p5.charged_at, id: p5.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts ascending with after cursor at end of collection", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :asc,
          after: encode_cursor(%{charged_at: p11.charged_at, id: p11.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts descending with before cursor at beginning of collection", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          before: encode_cursor(%{charged_at: p11.charged_at, id: p11.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts descending with after cursor at end of collection", %{
      payments: {_p1, _p2, _p3, _p4, p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          after: encode_cursor(%{charged_at: p5.charged_at, id: p5.id}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end
  end

  describe "paginate a collection of payments with customer filter, sorting by amount, charged_at" do
    test "multiple cursor_fields with pre-existing where filter in query", %{
      customers: {c1, _c2, _c3},
      payments: {_p1, _p2, _p3, _p4, p5, p6, p7, p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        customer_payments_by_charged_at_and_amount(c1)
        |> EctoInterface.TestRepo.paginate(cursor_fields: [:charged_at, :amount, :id], limit: 2)

      assert to_ids(entries) == to_ids([p5, p6])

      %EctoInterface.Paginator.Page{entries: entries, metadata: _metadata} =
        customer_payments_by_charged_at_and_amount(c1)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :amount, :id],
          limit: 2,
          after: metadata.after
        )

      assert to_ids(entries) == to_ids([p7, p8])
    end

    test "before cursor with multiple cursor_fields and pre-existing where filter in query", %{
      customers: {c1, _c2, _c3},
      payments: {_p1, _p2, _p3, _p4, _p5, p6, _p7, _p8, _p9, _p10, _p11, _p12}
    } do
      assert %EctoInterface.Paginator.Page{entries: [], metadata: _metadata} =
               customer_payments_by_charged_at_and_amount(c1)
               |> EctoInterface.TestRepo.paginate(
                 cursor_fields: [:amount, :charged_at, :id],
                 before:
                   encode_cursor(%{amount: p6.amount, charged_at: p6.charged_at, id: p6.id}),
                 limit: 1
               )
    end
  end

  describe "paginate a collection of payments, sorting by customer name" do
    test "raises error when binding not found", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, p11, _p12}
    } do
      assert_raise ArgumentError,
                   ~r{Could not find binding `bogus_binding` in query aliases: %\{(customer: 1, payments: 0|payments: 0, customer: 1)\}},
                   fn ->
                     %EctoInterface.Paginator.Page{} =
                       payments_by_customer_name()
                       |> EctoInterface.TestRepo.paginate(
                         cursor_fields: [
                           {{:bogus_binding, :id}, :asc},
                           {{:bogus_binding, :name}, :asc}
                         ],
                         limit: 50,
                         before:
                           encode_cursor(%{
                             {:bogus_binding, :id} => p11.id,
                             {:bogus_binding, :name} => p11.customer.name
                           })
                       )
                   end
    end

    test "sorts with mixed bindingless, bound columns", %{
      payments: {_p1, _p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{:id, :asc}, {{:customer, :name}, :asc}],
          before: encode_cursor(%{:id => p11.id, {:customer, :name} => p11.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p3, p4, p5, p6, p7, p8, p9, p10])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{:id => p10.id, {:customer, :name} => p10.customer.name}),
               before: encode_cursor(%{:id => p3.id, {:customer, :name} => p3.customer.name}),
               limit: 8
             }
    end

    test "sorts with mixed columns without direction and bound columns", %{
      payments: {_p1, _p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:id, {{:customer, :name}, :asc}],
          before: encode_cursor(%{:id => p11.id, {:customer, :name} => p11.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p3, p4, p5, p6, p7, p8, p9, p10])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{:id => p10.id, {:customer, :name} => p10.customer.name}),
               before: encode_cursor(%{:id => p3.id, {:customer, :name} => p3.customer.name}),
               limit: 8
             }
    end

    test "sorts ascending without cursors", %{
      payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :asc}, {{:customer, :name}, :asc}],
          limit: 50
        )

      assert to_ids(entries) == to_ids([p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 50}
    end

    test "sorts ascending with before cursor", %{
      payments: {_p1, _p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :asc}, {{:customer, :name}, :asc}],
          before:
            encode_cursor(%{{:payments, :id} => p11.id, {:customer, :name} => p11.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p3, p4, p5, p6, p7, p8, p9, p10])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after:
                 encode_cursor(%{
                   {:payments, :id} => p10.id,
                   {:customer, :name} => p10.customer.name
                 }),
               before:
                 encode_cursor(%{
                   {:payments, :id} => p3.id,
                   {:customer, :name} => p3.customer.name
                 }),
               limit: 8
             }
    end

    test "sorts ascending with after cursor", %{
      payments: {_p1, _p2, _p3, _p4, _p5, p6, p7, p8, p9, p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :asc}, {{:customer, :name}, :asc}],
          after:
            encode_cursor(%{{:payments, :id} => p6.id, {:customer, :name} => p6.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p7, p8, p9, p10, p11, p12])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: nil,
               before:
                 encode_cursor(%{
                   {:payments, :id} => p7.id,
                   {:customer, :name} => p7.customer.name
                 }),
               limit: 8
             }
    end

    test "sorts ascending with before and after cursor", %{
      payments: {_p1, _p2, _p3, _p4, _p5, p6, p7, p8, p9, p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :asc}, {{:customer, :name}, :asc}],
          after:
            encode_cursor(%{{:payments, :id} => p6.id, {:customer, :name} => p6.customer.name}),
          before:
            encode_cursor(%{{:payments, :id} => p10.id, {:customer, :name} => p10.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p7, p8, p9])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after:
                 encode_cursor(%{
                   {:payments, :id} => p9.id,
                   {:customer, :name} => p9.customer.name
                 }),
               before:
                 encode_cursor(%{
                   {:payments, :id} => p7.id,
                   {:customer, :name} => p7.customer.name
                 }),
               limit: 8
             }
    end

    test "sorts descending without cursors", %{
      payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name(:desc, :desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :desc}, {{:customer, :name}, :desc}],
          limit: 50
        )

      assert to_ids(entries) == to_ids([p12, p11, p10, p9, p8, p7, p6, p5, p4, p3, p2, p1])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 50}
    end

    test "sorts descending with before cursor", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :desc}, {{:customer, :name}, :desc}],
          before:
            encode_cursor(%{{:payments, :id} => p11.id, {:customer, :name} => p11.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p12])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after:
                 encode_cursor(%{
                   {:payments, :id} => p12.id,
                   {:customer, :name} => p12.customer.name
                 }),
               before: nil,
               limit: 8
             }
    end

    test "sorts descending with after cursor", %{
      payments: {_p1, _p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name(:desc, :desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :desc}, {{:customer, :name}, :desc}],
          sort_direction: :desc,
          after:
            encode_cursor(%{{:payments, :id} => p11.id, {:customer, :name} => p11.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p10, p9, p8, p7, p6, p5, p4, p3])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after:
                 encode_cursor(%{
                   {:payments, :id} => p3.id,
                   {:customer, :name} => p3.customer.name
                 }),
               before:
                 encode_cursor(%{
                   {:payments, :id} => p10.id,
                   {:customer, :name} => p10.customer.name
                 }),
               limit: 8
             }
    end

    test "sorts descending with before and after cursor", %{
      payments: {_p1, _p2, _p3, _p4, _p5, p6, p7, p8, p9, p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name(:desc, :desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :desc}, {{:customer, :name}, :desc}],
          after:
            encode_cursor(%{{:payments, :id} => p11.id, {:customer, :name} => p11.customer.name}),
          before:
            encode_cursor(%{{:payments, :id} => p6.id, {:customer, :name} => p6.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([p10, p9, p8, p7])

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after:
                 encode_cursor(%{
                   {:payments, :id} => p7.id,
                   {:customer, :name} => p7.customer.name
                 }),
               before:
                 encode_cursor(%{
                   {:payments, :id} => p10.id,
                   {:customer, :name} => p10.customer.name
                 }),
               limit: 8
             }
    end

    test "sorts ascending with before cursor at beginning of collection", %{
      payments: {p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :asc}, {{:customer, :name}, :asc}],
          before:
            encode_cursor(%{{:payments, :id} => p1.id, {:customer, :name} => p1.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts ascending with after cursor at end of collection", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :asc}, {{:customer, :name}, :asc}],
          after:
            encode_cursor(%{{:payments, :id} => p12.id, {:customer, :name} => p12.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts descending with before cursor at beginning of collection", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name(:desc, :desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :desc}, {{:customer, :name}, :desc}],
          before:
            encode_cursor(%{{:payments, :id} => p12.id, {:customer, :name} => p12.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts descending with after cursor at end of collection", %{
      payments: {p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_customer_name(:desc, :desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:payments, :id}, :desc}, {{:customer, :name}, :desc}],
          after:
            encode_cursor(%{{:payments, :id} => p1.id, {:customer, :name} => p1.customer.name}),
          limit: 8
        )

      assert to_ids(entries) == to_ids([])
      assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 8}
    end

    test "sorts on 2nd level join column with a custom cursor value function", %{
      payments: {_p1, _p2, _p3, _p4, p5, p6, p7, _p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_address_city()
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [{{:address, :city}, :asc}, id: :asc],
          before: nil,
          limit: 3,
          fetch_cursor_value_fun: fn
            schema, {:address, :city} ->
              schema.customer.address.city

            schema, field ->
              EctoInterface.Paginator.default_fetch_cursor_value(schema, field)
          end
        )

      assert to_ids(entries) == to_ids([p5, p6, p7])

      p7 = EctoInterface.TestRepo.preload(p7, customer: :address)

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after:
                 encode_cursor(%{{:address, :city} => p7.customer.address.city, :id => p7.id}),
               before: nil,
               limit: 3
             }
    end

    test "sorts with respect to nil values", %{
      payments: {_p1, _p2, _p3, _p4, _p5, _p6, p7, _p8, _p9, _p10, p11, _p12}
    } do
      %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
        payments_by_charged_at(:desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:charged_at, :id],
          sort_direction: :desc,
          after: encode_cursor(%{charged_at: nil, id: -1}),
          limit: 8
        )

      assert Enum.count(entries) == 8

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               before: encode_cursor(%{charged_at: p11.charged_at, id: p11.id}),
               limit: 8,
               after: encode_cursor(%{charged_at: p7.charged_at, id: p7.id})
             }
    end
  end

  test "applies a default limit if none is provided", %{
    payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}
  } do
    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      payments_by_customer_name()
      |> EctoInterface.TestRepo.paginate(cursor_fields: [:id], sort_direction: :asc)

    assert to_ids(entries) == to_ids([p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12])
    assert metadata == %EctoInterface.Paginator.PageMetadata{after: nil, before: nil, limit: 50}
  end

  test "enforces the minimum limit", %{
    payments: {p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
  } do
    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      payments_by_customer_name()
      |> EctoInterface.TestRepo.paginate(cursor_fields: [:id], sort_direction: :asc, limit: 0)

    assert to_ids(entries) == to_ids([p1])

    assert metadata == %EctoInterface.Paginator.PageMetadata{
             after: encode_cursor(%{id: p1.id}),
             before: nil,
             limit: 1
           }
  end

  describe "with include_total_count" do
    test "when set to :infinity", %{
      payments: {_p1, _p2, _p3, _p4, p5, _p6, _p7, _p8, _p9, p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{metadata: metadata} =
        from(p in EctoInterfaceContext.Payment)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:id],
          limit: 5,
          total_count_limit: :infinity,
          include_total_count: true
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{id: p5.id}),
               last_page_after: encode_cursor(%{id: p10.id}),
               before: nil,
               limit: 5,
               total_count: 12,
               total_count_cap_exceeded: false,
               total_pages: 3
             }
    end

    test "when cap not exceeded", %{
      payments: {_p1, _p2, _p3, _p4, p5, _p6, _p7, _p8, _p9, p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{metadata: metadata} =
        from(p in EctoInterfaceContext.Payment)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:id],
          limit: 5,
          include_total_count: true
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{id: p5.id}),
               last_page_after: encode_cursor(%{id: p10.id}),
               before: nil,
               limit: 5,
               total_count: 12,
               total_count_cap_exceeded: false,
               total_pages: 3
             }
    end

    test "when cap exceeded", %{
      payments: {_p1, _p2, _p3, _p4, p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{metadata: metadata} =
        from(p in EctoInterfaceContext.Payment)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:id],
          limit: 5,
          include_total_count: true,
          total_count_limit: 10
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{id: p5.id}),
               before: nil,
               last_page_after: encode_cursor(%{id: p5.id}),
               limit: 5,
               total_count: 10,
               total_count_cap_exceeded: true,
               total_pages: 2
             }
    end

    test "when custom total_count_primary_key_field", %{
      addresses: {_a1, a2, _a3}
    } do
      %EctoInterface.Paginator.Page{metadata: metadata} =
        from(a in EctoInterfaceContext.Address, select: a)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [:city],
          sort_direction: :asc,
          limit: 2,
          include_total_count: true,
          total_count_primary_key_field: :city
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{city: a2.city}),
               last_page_after: encode_cursor(%{city: a2.city}),
               before: nil,
               limit: 2,
               total_count: 3,
               total_count_cap_exceeded: false,
               total_pages: 2
             }
    end

    test "when there are no results" do
      %EctoInterface.Paginator.Page{metadata: metadata} =
        from(a in EctoInterfaceContext.Address, where: a.city == "Mauá")
        |> EctoInterface.TestRepo.paginate(
          limit: 5,
          include_total_count: true,
          cursor_fields: [:city],
          total_count_primary_key_field: :city
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: nil,
               before: nil,
               last_page_after: nil,
               limit: 5,
               total_count: 0,
               total_count_cap_exceeded: false,
               total_pages: 0
             }
    end

    test "when there is a last page", %{
      payments: {_p1, _p2, _p3, _p4, p5, p6, _p7, _p8, _p9, p10, _p11, _p12}
    } do
      %EctoInterface.Paginator.Page{metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          after: encode_cursor(%{id: p5.id}),
          cursor_fields: [id: :asc],
          limit: 5,
          total_count_limit: :infinity,
          include_total_count: true
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{id: p10.id}),
               before: encode_cursor(%{id: p6.id}),
               last_page_after: encode_cursor(%{id: p10.id}),
               limit: 5,
               total_count: 12,
               total_count_cap_exceeded: false,
               total_pages: 3
             }

      %EctoInterface.Paginator.Page{metadata: metadata} =
        payments_by_customer_name()
        |> EctoInterface.TestRepo.paginate(
          after: encode_cursor(%{id: p5.id}),
          cursor_fields: [id: :asc],
          limit: 5,
          total_count_limit: 10,
          include_total_count: true
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(%{id: p10.id}),
               before: encode_cursor(%{id: p6.id}),
               last_page_after: encode_cursor(%{id: p5.id}),
               limit: 5,
               total_count: 10,
               total_count_cap_exceeded: true,
               total_pages: 2
             }
    end

    test "when there are multiple cursor_fields", %{} do
      # [p6, p4, p5, p7, p8, p12, p2, p9, p11, p3, p1, p10] =
      [_p1, _p2, _p3, _p4, p5, p6, _p7, _p8, _p9, p10, _p11, _p12] =
        payments_by_amount_and_charged_at(:asc, :desc)
        |> EctoInterface.TestRepo.all()

      cursor_field_list = [:amount, :charged_at, :id]

      %EctoInterface.Paginator.Page{metadata: metadata} =
        payments_by_amount_and_charged_at(:asc, :desc)
        |> EctoInterface.TestRepo.paginate(
          after: encode_cursor(p5, cursor_field_list),
          cursor_fields: [amount: :asc, charged_at: :desc, id: :asc],
          limit: 5,
          total_count_limit: :infinity,
          include_total_count: true
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(p10, cursor_field_list),
               before: encode_cursor(p6, cursor_field_list),
               last_page_after: encode_cursor(p10, cursor_field_list),
               limit: 5,
               total_count: 12,
               total_count_cap_exceeded: false,
               total_pages: 3
             }
    end

    test "when total is a multiple of limit and limit exceeds", %{} do
      # [6, 4, 5, 7, 8, 10, 2, 1, 9, 3]
      [_p1, _p2, _p3, _p4, p5, _p6, _p7, _p8, _p9, _p10] =
        payments_by_amount_and_charged_at(:asc, :desc)
        |> limit(10)
        |> EctoInterface.TestRepo.all()

      cursor_field_list = [:amount, :charged_at, :id]

      %EctoInterface.Paginator.Page{metadata: metadata} =
        payments_by_amount_and_charged_at(:asc, :desc)
        |> EctoInterface.TestRepo.paginate(
          cursor_fields: [amount: :asc, charged_at: :desc, id: :asc],
          limit: 5,
          total_count_limit: 10,
          include_total_count: true
        )

      assert metadata == %EctoInterface.Paginator.PageMetadata{
               after: encode_cursor(p5, cursor_field_list),
               before: nil,
               last_page_after: encode_cursor(p5, cursor_field_list),
               limit: 5,
               total_count: 10,
               total_count_cap_exceeded: true,
               total_pages: 2
             }
    end
  end

  test "when before parameter is erlang term, we do not execute the code", %{} do
    # before and after, are user inputs, we need to make sure that they are
    # handled safely.

    test_pid = self()

    exploit = fn _, _ ->
      send(test_pid, :rce)
      {:cont, []}
    end

    payload =
      exploit
      |> :erlang.term_to_binary()
      |> Base.url_encode64()

    assert_raise(ArgumentError, ~r/^cannot deserialize.+/, fn ->
      payments_by_amount_and_charged_at(:asc, :desc)
      |> EctoInterface.TestRepo.paginate(
        cursor_fields: [amount: :asc, charged_at: :desc, id: :asc],
        before: payload,
        limit: 3
      )
    end)

    refute_receive :rce, 1000, "Remote Code Execution Detected"
  end

  test "per-record cursor generation", %{
    payments: {p1, _p2, _p3, _p4, _p5, _p6, p7, _p8, _p9, _p10, _p11, _p12}
  } do
    assert EctoInterface.Paginator.cursor_for_record(p1, charged_at: :asc, id: :asc) ==
             encode_cursor(%{charged_at: p1.charged_at, id: p1.id})

    assert EctoInterface.Paginator.cursor_for_record(p7, amount: :asc) ==
             encode_cursor(%{amount: p7.amount})
  end

  test "per-record cursor generation with custom cursor value function", %{
    payments: {p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12}
  } do
    assert EctoInterface.Paginator.cursor_for_record(p1, [charged_at: :asc, id: :asc], fn schema,
                                                                                          field ->
             case field do
               :id -> Map.get(schema, :id)
               _ -> "10"
             end
           end) == encode_cursor(%{charged_at: "10", id: p1.id})
  end

  test "sorts on two different directions with before cursor", %{
    payments: {_p1, _p2, _p3, p4, p5, p6, p7, _p8, _p9, _p10, _p11, _p12}
  } do
    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      payments_by_amount_and_charged_at(:asc, :desc)
      |> EctoInterface.TestRepo.paginate(
        cursor_fields: [amount: :asc, charged_at: :desc, id: :asc],
        before: encode_cursor(%{amount: p7.amount, charged_at: p7.charged_at, id: p7.id}),
        limit: 3
      )

    assert to_ids(entries) == to_ids([p6, p4, p5])

    assert metadata == %EctoInterface.Paginator.PageMetadata{
             after: encode_cursor(%{amount: p5.amount, charged_at: p5.charged_at, id: p5.id}),
             before: nil,
             limit: 3
           }
  end

  test "sorts on two different directions with after cursor", %{
    payments: {_p1, _p2, _p3, p4, p5, _p6, p7, p8, _p9, _p10, _p11, _p12}
  } do
    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      payments_by_amount_and_charged_at(:asc, :desc)
      |> EctoInterface.TestRepo.paginate(
        cursor_fields: [amount: :asc, charged_at: :desc, id: :asc],
        after: encode_cursor(%{amount: p4.amount, charged_at: p4.charged_at, id: p4.id}),
        limit: 3
      )

    assert to_ids(entries) == to_ids([p5, p7, p8])

    assert metadata == %EctoInterface.Paginator.PageMetadata{
             after: encode_cursor(%{amount: p8.amount, charged_at: p8.charged_at, id: p8.id}),
             before: encode_cursor(%{amount: p5.amount, charged_at: p5.charged_at, id: p5.id}),
             limit: 3
           }
  end

  test "sorts on two different directions with before and after cursor", %{
    payments: {_p1, _p2, _p3, p4, p5, p6, p7, p8, _p9, _p10, _p11, _p12}
  } do
    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      payments_by_amount_and_charged_at(:desc, :asc)
      |> EctoInterface.TestRepo.paginate(
        cursor_fields: [amount: :desc, charged_at: :asc, id: :asc],
        after: encode_cursor(%{amount: p8.amount, charged_at: p8.charged_at, id: p8.id}),
        before: encode_cursor(%{amount: p6.amount, charged_at: p6.charged_at, id: p6.id}),
        limit: 8
      )

    assert to_ids(entries) == to_ids([p7, p5, p4])

    assert metadata == %EctoInterface.Paginator.PageMetadata{
             after: encode_cursor(%{amount: p4.amount, charged_at: p4.charged_at, id: p4.id}),
             before: encode_cursor(%{amount: p7.amount, charged_at: p7.charged_at, id: p7.id}),
             limit: 8
           }
  end

  @available_sorting_order [
    :asc,
    :asc_nulls_last,
    :asc_nulls_first,
    :desc,
    :desc_nulls_first,
    :desc_nulls_last
  ]

  for order <- @available_sorting_order do
    test "throw an error if nulls are used in the last term - order_by charged_at #{order}" do
      customer = insert(:customer)
      insert(:payment, customer: customer, charged_at: NaiveDateTime.utc_now())
      insert(:payment, customer: customer, charged_at: nil)
      insert(:payment, customer: customer, charged_at: nil)

      opts = [
        cursor_fields: [charged_at: unquote(order)],
        limit: 1
      ]

      query =
        from(
          p in EctoInterfaceContext.Payment,
          where: p.customer_id == ^customer.id,
          order_by: [{^unquote(order), p.charged_at}],
          select: p
        )

      assert_raise RuntimeError, fn -> paginate_as_list(query, opts) end
    end
  end

  for field0_order <- @available_sorting_order, field1_order <- @available_sorting_order do
    test "paginates correctly when pages contains nulls - order by charged_at #{field0_order}, id #{field1_order}" do
      customer = insert(:customer)

      now = NaiveDateTime.utc_now()

      for k <- 1..50 do
        if Enum.random([true, false]) do
          if Enum.random([true, false]) do
            insert(:payment, customer: customer, charged_at: NaiveDateTime.add(now, k))
          else
            insert(:payment, customer: customer, charged_at: NaiveDateTime.add(now, k - 1))
          end
        else
          insert(:payment, customer: customer, charged_at: nil)
        end
      end

      opts = [
        cursor_fields: [charged_at: unquote(field0_order), id: unquote(field1_order)],
        limit: 1
      ]

      query =
        from(
          p in EctoInterfaceContext.Payment,
          where: p.customer_id == ^customer.id,
          order_by: [{^unquote(field0_order), p.charged_at}, {^unquote(field1_order), p.id}],
          select: p
        )

      expected =
        query
        |> EctoInterface.TestRepo.all(opts)
        |> to_ids()

      after_pagination = paginate_as_list(query, opts)
      assert after_pagination == expected

      before_pagination = paginate_before_as_list(query, opts)
      assert before_pagination == init([nil | expected])
    end
  end

  test "expression based field is passed to cursor_fields" do
    base_customer_name = "Bob"

    list = create_customers_with_similar_names(base_customer_name)

    {:ok, customer_3} = Enum.fetch(list, 3)

    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      base_customer_name
      |> customers_with_tsvector_rank()
      |> EctoInterface.TestRepo.paginate(
        after: encode_cursor(%{rank_value: customer_3.rank_value, id: customer_3.id}),
        limit: 3,
        cursor_fields: [
          {:rank_value,
           fn ->
             dynamic(
               [x],
               fragment(
                 "ts_rank(setweight(to_tsvector('simple', name), 'A'), plainto_tsquery('simple', ?))",
                 ^base_customer_name
               )
             )
           end},
          :id
        ]
      )

    last_entry = List.last(entries)
    first_entry = List.first(entries)

    assert metadata == %EctoInterface.Paginator.PageMetadata{
             after: encode_cursor(%{rank_value: last_entry.rank_value, id: last_entry.id}),
             before: encode_cursor(%{rank_value: first_entry.rank_value, id: first_entry.id}),
             limit: 3
           }
  end

  test "expression based field when combined with UUID field" do
    base_customer_name = "Bob"

    create_customers_with_similar_names(base_customer_name)

    list = base_customer_name |> customers_with_tsvector_rank() |> EctoInterface.TestRepo.all()
    {:ok, customer_3} = Enum.fetch(list, 3)

    %EctoInterface.Paginator.Page{entries: entries, metadata: metadata} =
      base_customer_name
      |> customers_with_tsvector_rank()
      |> EctoInterface.TestRepo.paginate(
        after:
          encode_cursor(%{
            rank_value: customer_3.rank_value,
            internal_uuid: customer_3.internal_uuid
          }),
        limit: 3,
        cursor_fields: [
          {:rank_value,
           fn ->
             dynamic(
               [x],
               fragment(
                 "ts_rank(setweight(to_tsvector('simple', name), 'A'), plainto_tsquery('simple', ?))",
                 ^base_customer_name
               )
             )
           end},
          :internal_uuid
        ]
      )

    last_entry = List.last(entries)
    first_entry = List.first(entries)

    assert metadata == %EctoInterface.Paginator.PageMetadata{
             after:
               encode_cursor(%{
                 rank_value: last_entry.rank_value,
                 internal_uuid: last_entry.internal_uuid
               }),
             before:
               encode_cursor(%{
                 rank_value: first_entry.rank_value,
                 internal_uuid: first_entry.internal_uuid
               }),
             limit: 3
           }
  end

  defp to_ids(entries), do: Enum.map(entries, & &1.id)

  defp create_customers_and_payments(_context) do
    c1 = insert(:customer, %{name: "Bob", internal_uuid: Ecto.UUID.generate()})
    c2 = insert(:customer, %{name: "Alice", internal_uuid: Ecto.UUID.generate()})
    c3 = insert(:customer, %{name: "Charlie", internal_uuid: Ecto.UUID.generate()})

    a1 = insert(:address, city: "London", customer: c1)
    a2 = insert(:address, city: "New York", customer: c2)
    a3 = insert(:address, city: "Tokyo", customer: c3)

    p1 = insert(:payment, customer: c2, charged_at: days_ago(11))
    p2 = insert(:payment, customer: c2, charged_at: days_ago(6))
    p3 = insert(:payment, customer: c2, charged_at: days_ago(8))
    p4 = insert(:payment, customer: c2, amount: 2, charged_at: days_ago(12))

    p5 = insert(:payment, customer: c1, amount: 3, charged_at: days_ago(13))
    p6 = insert(:payment, customer: c1, amount: 2, charged_at: days_ago(10))
    p7 = insert(:payment, customer: c1, amount: 4, charged_at: days_ago(9))
    p8 = insert(:payment, customer: c1, amount: 5, charged_at: days_ago(4))

    p9 = insert(:payment, customer: c3, charged_at: days_ago(3))
    p10 = insert(:payment, customer: c3, charged_at: days_ago(7))
    p11 = insert(:payment, customer: c3, charged_at: days_ago(2))
    p12 = insert(:payment, customer: c3, charged_at: days_ago(5))

    {:ok,
     customers: {c1, c2, c3},
     addresses: {a1, a2, a3},
     payments: {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12}}
  end

  defp create_customers_with_similar_names(base_customer_name) do
    1..10
    |> Enum.map(fn i ->
      {:ok, %{rows: [[rank_value]]}} =
        EctoInterface.TestRepo.query(
          "SELECT ts_rank(setweight(to_tsvector('simple', $1), 'A'), plainto_tsquery('simple', $2))",
          [
            "#{base_customer_name} #{i}",
            base_customer_name
          ]
        )

      insert(:customer, %{
        name: "#{base_customer_name} #{i}",
        internal_uuid: Ecto.UUID.generate(),
        rank_value: rank_value
      })
    end)
  end

  defp payments_by_status(status, direction \\ :asc) do
    from(
      p in EctoInterfaceContext.Payment,
      where: p.status == ^status,
      order_by: [{^direction, p.charged_at}, {^direction, p.id}],
      select: p
    )
  end

  defp payments_by_amount_and_charged_at(amount_direction, charged_at_direction) do
    from(
      p in EctoInterfaceContext.Payment,
      order_by: [
        {^amount_direction, p.amount},
        {^charged_at_direction, p.charged_at},
        {:asc, p.id}
      ],
      select: p
    )
  end

  defp payments_by_charged_at(direction \\ :asc) do
    from(
      p in EctoInterfaceContext.Payment,
      order_by: [{^direction, p.charged_at}, {^direction, p.id}],
      select: p
    )
  end

  defp payments_by_customer_name(payment_id_direction \\ :asc, customer_name_direction \\ :asc) do
    from(
      p in EctoInterfaceContext.Payment,
      as: :payments,
      join: c in assoc(p, :customer),
      as: :customer,
      preload: [customer: c],
      select: p,
      order_by: [
        {^customer_name_direction, c.name},
        {^payment_id_direction, p.id}
      ]
    )
  end

  defp payments_by_address_city(payment_id_direction \\ :asc, address_city_direction \\ :asc) do
    from(
      p in EctoInterfaceContext.Payment,
      as: :payments,
      join: c in assoc(p, :customer),
      as: :customer,
      join: a in assoc(c, :address),
      as: :address,
      preload: [customer: {c, address: a}],
      select: p,
      order_by: [
        {^address_city_direction, a.city},
        {^payment_id_direction, p.id}
      ]
    )
  end

  defp customer_payments_by_charged_at_and_amount(customer, direction \\ :asc) do
    from(
      p in EctoInterfaceContext.Payment,
      where: p.customer_id == ^customer.id,
      order_by: [{^direction, p.charged_at}, {^direction, p.amount}, {^direction, p.id}]
    )
  end

  defp customers_with_tsvector_rank(q) do
    from(f in EctoInterfaceContext.Customer,
      select_merge: %{
        rank_value:
          fragment(
            "ts_rank(setweight(to_tsvector('simple', name), 'A'), plainto_tsquery('simple', ?)) AS rank_value",
            ^q
          )
      },
      where:
        fragment(
          "setweight(to_tsvector('simple', name), 'A') @@ plainto_tsquery('simple', ?)",
          ^q
        ),
      order_by: [
        asc: fragment("rank_value"),
        asc: f.internal_uuid
      ]
    )
  end

  defp encode_cursor(record, fields) do
    Map.take(record, fields)
    |> EctoInterface.Paginator.Cursor.encode()
  end

  defp encode_cursor(value) do
    EctoInterface.Paginator.Cursor.encode(value)
  end

  defp encode_legacy_cursor(value) when is_list(value) do
    value
    |> :erlang.term_to_binary()
    |> Base.url_encode64()
  end

  defp days_ago(days) do
    DT.add!(DateTime.utc_now(), -(days * 86_400))
  end

  defp paginate_as_list(query, opts, mapf \\ &to_ids(&1.entries)) do
    opts
    |> Stream.unfold(fn
      nil ->
        nil

      opts ->
        page = EctoInterface.TestRepo.paginate(query, opts)

        if after_value = page.metadata.after do
          {mapf.(page), Keyword.put(opts, :after, after_value)}
        else
          {mapf.(page), nil}
        end
    end)
    |> Stream.flat_map(& &1)
    |> Enum.to_list()
  end

  defp paginate_before_as_list(query, opts) do
    query
    |> paginate_as_list(opts, &[&1.metadata.before])
    |> Enum.flat_map(fn
      nil ->
        [nil]

      before_cursor ->
        EctoInterface.TestRepo.paginate(query, Keyword.put(opts, :before, before_cursor))
        |> Map.fetch!(:entries)
        |> to_ids
    end)
  end

  defp init([]) do
    []
  end

  defp init([_]) do
    []
  end

  defp init([x | xs]) do
    [x | init(xs)]
  end
end
