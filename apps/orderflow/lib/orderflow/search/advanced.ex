defmodule Orderflow.Search.Advanced do
  @moduledoc """
  Advanced search with faceted search, aggregations, and filters.
  Elasticsearch-style functionality using PostgreSQL.
  """
  import Ecto.Query

  alias Orderflow.Catalog.Product
  alias Orderflow.Repo

  @doc """
  Faceted search with filters, aggregations, and sorting.
  """
  def faceted_search(query_string, filters \\ %{}, opts \\ []) do
    base_query =
      Product
      |> where([p], is_nil(p.deleted_at))
      |> apply_filters(filters)
      |> apply_search(query_string)
      |> apply_sorting(opts[:sort])

    # Get results
    results =
      base_query
      |> limit(^Keyword.get(opts, :limit, 20))
      |> offset(^Keyword.get(opts, :offset, 0))
      |> preload(:category)
      |> Repo.all()

    # Get aggregations
    aggregations = %{
      categories: aggregate_by_category(base_query),
      price_ranges: aggregate_by_price_range(base_query),
      total_count: count_total(base_query)
    }

    %{
      results: results,
      aggregations: aggregations,
      total: aggregations.total_count
    }
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:category_id, id}, q -> where(q, [p], p.category_id == ^id)
      {:min_price, price}, q -> where(q, [p], p.price >= ^price)
      {:max_price, price}, q -> where(q, [p], p.price <= ^price)
      {:in_stock, true}, q -> where(q, [p], p.stock > 0)
      {:active, status}, q -> where(q, [p], p.active == ^status)
      _, q -> q
    end)
  end

  defp apply_search(query, nil), do: query
  defp apply_search(query, ""), do: query

  defp apply_search(query, term) do
    search = "%#{term}%"

    where(
      query,
      [p],
      ilike(p.name, ^search) or
        ilike(p.description, ^search)
    )
  end

  defp apply_sorting(query, nil), do: order_by(query, [p], desc: p.inserted_at)
  defp apply_sorting(query, "price_asc"), do: order_by(query, [p], asc: p.price)
  defp apply_sorting(query, "price_desc"), do: order_by(query, [p], desc: p.price)
  defp apply_sorting(query, "name_asc"), do: order_by(query, [p], asc: p.name)
  defp apply_sorting(query, "name_desc"), do: order_by(query, [p], desc: p.name)
  defp apply_sorting(query, "stock"), do: order_by(query, [p], desc: p.stock)
  defp apply_sorting(query, _), do: order_by(query, [p], desc: p.inserted_at)

  defp aggregate_by_category(query) do
    query
    |> join(:inner, [p], c in Orderflow.Catalog.Category, on: p.category_id == c.id)
    |> group_by([p, c], c.name)
    |> select([p, c], {c.name, count(p.id)})
    |> Repo.all()
  end

  defp aggregate_by_price_range(query) do
    ranges = [
      {"Under $10", 0, 10},
      {"$10 - $20", 10, 20},
      {"$20 - $50", 20, 50},
      {"$50+", 50, 999_999}
    ]

    Enum.map(ranges, fn {label, min, max} ->
      count =
        query
        |> where([p], p.price >= ^min and p.price < ^max)
        |> select([p], count(p.id))
        |> Repo.one()

      %{label: label, count: count}
    end)
  end

  defp count_total(query) do
    query
    |> select([p], count(p.id))
    |> Repo.one()
  end
end
