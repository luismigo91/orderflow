defmodule Orderflow.Pagination do
  @moduledoc """
  Cursor-based pagination for Ecto queries.
  """
  import Ecto.Query

  @default_limit 20
  @max_limit 100

  @doc """
  Paginate a query with cursor-based pagination.
  Returns {results, next_cursor, has_more?}.
  """
  def paginate(query, cursor \\ nil, limit \\ @default_limit) do
    limit = min(limit, @max_limit)

    query =
      if cursor do
        where(query, [r], r.id > ^cursor)
      else
        query
      end

    results =
      query
      |> limit(^limit)
      |> order_by(asc: :id)
      |> Orderflow.Repo.all()

    has_more = length(results) == limit
    next_cursor = if has_more, do: List.last(results).id, else: nil

    {results, next_cursor, has_more}
  end

  @doc """
  Serialize pagination metadata for JSON responses.
  """
  def metadata(results, next_cursor, has_more) do
    %{
      count: length(results),
      next_cursor: next_cursor,
      has_more: has_more
    }
  end
end
