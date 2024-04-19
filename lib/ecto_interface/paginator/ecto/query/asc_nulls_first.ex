defmodule EctoInterface.Paginator.Ecto.Query.AscNullsFirst do
  @behaviour EctoInterface.Paginator.Ecto.Query.DynamicFilterBuilder

  import Ecto.Query
  import EctoInterface.Paginator.Ecto.Query.FieldOrExpression

  @impl EctoInterface.Paginator.Ecto.Query.DynamicFilterBuilder
  def build_dynamic_filter(%{direction: :after, value: nil, next_filters: true}) do
    raise("unstable sort order: nullable columns can't be used as the last term")
  end

  def build_dynamic_filter(%{direction: :after, value: nil} = args) do
    dynamic(
      [{query, args.entity_position}],
      (^field_or_expr_is_nil(args) and ^args.next_filters) or
        not (^field_or_expr_is_nil(args))
    )
  end

  def build_dynamic_filter(%{direction: :after, next_filters: true} = args) do
    dynamic(
      [{query, args.entity_position}],
      ^field_or_expr_greater(args)
    )
  end

  def build_dynamic_filter(%{direction: :after} = args) do
    dynamic(
      [{query, args.entity_position}],
      (^field_or_expr_equal(args) and ^args.next_filters) or
        ^field_or_expr_greater(args)
    )
  end

  def build_dynamic_filter(%{direction: :before, value: nil, next_filters: true}) do
    raise("unstable sort order: nullable columns can't be used as the last term")
  end

  def build_dynamic_filter(%{direction: :before, value: nil} = args) do
    dynamic(
      [{query, args.entity_position}],
      ^field_or_expr_is_nil(args) and ^args.next_filters
    )
  end

  def build_dynamic_filter(%{direction: :before, next_filters: true} = args) do
    dynamic(
      [{query, args.entity_position}],
      ^field_or_expr_less(args) or ^field_or_expr_is_nil(args)
    )
  end

  def build_dynamic_filter(%{direction: :before} = args) do
    dynamic(
      [{query, args.entity_position}],
      (^field_or_expr_equal(args) and ^args.next_filters) or
        ^field_or_expr_less(args) or
        ^field_or_expr_is_nil(args)
    )
  end
end
