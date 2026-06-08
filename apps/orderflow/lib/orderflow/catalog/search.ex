defmodule Orderflow.Catalog.Search do
  @moduledoc """
  Full-text search for products using PostgreSQL tsvector.
  """
  import Ecto.Query

  alias Orderflow.Catalog.Product
  alias Orderflow.Repo

  @doc """
  Search products by name and description using full-text search.
  Falls back to ILIKE for partial matches.
  """
  def search_products(query_string) when is_binary(query_string) and query_string != "" do
    search_term = String.trim(query_string)

    # Full-text search using tsvector
    fts_query =
      from p in Product,
        where:
          fragment(
            "? @@ plainto_tsquery('spanish', ?)",
            p.search_vector,
            ^search_term
          ),
        order_by:
          fragment(
            "ts_rank(?, plainto_tsquery('spanish', ?)) DESC",
            p.search_vector,
            ^search_term
          )

    # Fallback ILIKE for partial matches
    ilike_query =
      from p in Product,
        where: ilike(p.name, ^"%#{search_term}%") or ilike(p.description, ^"%#{search_term}%")

    fts_results = Repo.all(fts_query)
    ilike_results = Repo.all(ilike_query)

    # Combine results, removing duplicates
    (fts_results ++ ilike_results)
    |> Enum.uniq_by(& &1.id)
  end

  def search_products(_), do: []
end
