defmodule Orderflow.Catalog.Filters do
  @moduledoc """
  Advanced filtering for products with multiple criteria.
  """
  import Ecto.Query

  alias Orderflow.Catalog.Product
  alias Orderflow.Repo

  @doc """
  Filter products by multiple criteria:
  - category_id
  - min_price / max_price
  - in_stock (boolean)
  - active (boolean)
  - search_term (text search)
  """
  def filter_products(criteria) do
    Product
    |> maybe_filter_by_category(criteria[:category_id])
    |> maybe_filter_by_price_range(criteria[:min_price], criteria[:max_price])
    |> maybe_filter_by_stock(criteria[:in_stock])
    |> maybe_filter_by_active(criteria[:active])
    |> maybe_filter_by_search(criteria[:search_term])
    |> preload(:category)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  defp maybe_filter_by_category(query, nil), do: query

  defp maybe_filter_by_category(query, category_id) do
    where(query, [p], p.category_id == ^category_id)
  end

  defp maybe_filter_by_price_range(query, nil, nil), do: query

  defp maybe_filter_by_price_range(query, min_price, nil) do
    where(query, [p], p.price >= ^min_price)
  end

  defp maybe_filter_by_price_range(query, nil, max_price) do
    where(query, [p], p.price <= ^max_price)
  end

  defp maybe_filter_by_price_range(query, min_price, max_price) do
    where(query, [p], p.price >= ^min_price and p.price <= ^max_price)
  end

  defp maybe_filter_by_stock(query, nil), do: query

  defp maybe_filter_by_stock(query, true) do
    where(query, [p], p.stock > 0)
  end

  defp maybe_filter_by_stock(query, false) do
    where(query, [p], p.stock == 0)
  end

  defp maybe_filter_by_active(query, nil), do: query

  defp maybe_filter_by_active(query, active) do
    where(query, [p], p.active == ^active)
  end

  defp maybe_filter_by_search(query, nil), do: query
  defp maybe_filter_by_search(query, ""), do: query

  defp maybe_filter_by_search(query, term) do
    search = "%#{term}%"
    where(query, [p], ilike(p.name, ^search) or ilike(p.description, ^search))
  end
end
