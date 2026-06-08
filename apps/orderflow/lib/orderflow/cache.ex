defmodule Orderflow.Cache do
  @moduledoc """
  Simple ETS-based cache for frequently accessed data.
  """
  use GenServer

  @table :orderflow_cache
  # 5 minutes
  @ttl_seconds 300

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    {:ok, %{}}
  end

  @doc """
  Get a value from cache.
  """
  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, value, expires_at}] ->
        if System.monotonic_time(:second) < expires_at do
          {:ok, value}
        else
          :ets.delete(@table, key)
          :miss
        end

      [] ->
        :miss
    end
  end

  @doc """
  Put a value in cache with TTL.
  """
  def put(key, value, ttl \\ @ttl_seconds) do
    expires_at = System.monotonic_time(:second) + ttl
    :ets.insert(@table, {key, value, expires_at})
    :ok
  end

  @doc """
  Delete a key from cache.
  """
  def delete(key) do
    :ets.delete(@table, key)
    :ok
  end

  @doc """
  Get or compute a value.
  """
  def get_or_compute(key, compute_fn, ttl \\ @ttl_seconds) do
    case get(key) do
      {:ok, value} ->
        value

      :miss ->
        value = compute_fn.()
        put(key, value, ttl)
        value
    end
  end

  @doc """
  Clear all cached entries.
  """
  def clear do
    :ets.delete_all_objects(@table)
    :ok
  end
end
