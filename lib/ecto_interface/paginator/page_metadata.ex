defmodule EctoInterface.Paginator.PageMetadata do
  @moduledoc """
  Defines page metadata.

  ## Fields

  * `after` - an opaque cursor representing the last row of the current page.
  * `before` - an opaque cursor representing the first row of the current page.
  * `limit` - the maximum number of entries that can be contained in this page.
  * `total_count` - the total number of entries matching the query. Requires
  `include_total_count`.
  * `total_count_cap_exceeded` - a boolean indicating whether the
  `:total_count_limit` was exceeded. Requires `include_total_count`.
  * `total_pages` - the estimated number of pages, given `limit` and
  `total_count`. Requires `include_total_count`.
  * `last_page_after` - an opaque cursor representing the record from which the
  last page starts. Requires `include_total_count`.
  """

  @type opaque_cursor :: String.t()

  @type t :: %__MODULE__{
          after: opaque_cursor() | nil,
          before: opaque_cursor() | nil,
          last_page_after: opaque_cursor() | nil,
          limit: integer(),
          total_count: integer() | nil,
          total_count_cap_exceeded: boolean() | nil,
          total_pages: integer() | nil
        }

  defstruct [
    :after,
    :before,
    :limit,
    :total_count,
    :total_count_cap_exceeded,
    :total_pages,
    :last_page_after
  ]
end
