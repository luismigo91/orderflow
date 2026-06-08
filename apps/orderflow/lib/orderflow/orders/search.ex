defmodule Orderflow.Orders.Search do
  @moduledoc """
  Advanced order search with filters.
  """
  import Ecto.Query
  alias Orderflow.Orders.Order
  alias Orderflow.Repo

  def search_orders(criteria) do
    Order
    |> maybe_filter_by_status(criteria[:status])
    |> maybe_filter_by_customer(criteria[:customer_name])
    |> maybe_filter_by_date_range(criteria[:start_date], criteria[:end_date])
    |> maybe_filter_by_min_total(criteria[:min_total])
    |> maybe_filter_by_max_total(criteria[:max_total])
    |> preload([:order_items, :user])
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status), do: where(query, [o], o.status == ^status)

  defp maybe_filter_by_customer(query, nil), do: query

  defp maybe_filter_by_customer(query, name),
    do: where(query, [o], ilike(o.customer_name, ^"%#{name}%"))

  defp maybe_filter_by_date_range(query, nil, nil), do: query

  defp maybe_filter_by_date_range(query, start_date, nil) do
    where(query, [o], o.inserted_at >= ^start_date)
  end

  defp maybe_filter_by_date_range(query, nil, end_date) do
    where(query, [o], o.inserted_at <= ^end_date)
  end

  defp maybe_filter_by_date_range(query, start_date, end_date) do
    where(query, [o], o.inserted_at >= ^start_date and o.inserted_at <= ^end_date)
  end

  defp maybe_filter_by_min_total(query, nil), do: query
  defp maybe_filter_by_min_total(query, min), do: where(query, [o], o.total >= ^min)

  defp maybe_filter_by_max_total(query, nil), do: query
  defp maybe_filter_by_max_total(query, max), do: where(query, [o], o.total <= ^max)
end
