defmodule Orderflow.CircuitBreaker do
  @moduledoc """
  Circuit breaker pattern for external API calls.
  Prevents cascade failures when external services are down.
  """
  use GenServer

  @failure_threshold 5
  @timeout_ms 30000
  @half_open_timeout 60000

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @impl true
  def init(_) do
    {:ok, %{state: :closed, failures: 0, last_failure: nil, success_count: 0}}
  end

  @doc """
  Call a function with circuit breaker protection.
  """
  def call(name, fun, timeout \\ @timeout_ms) do
    GenServer.call(name, {:call, fun, timeout}, :infinity)
  end

  @doc """
  Get current circuit state.
  """
  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  @impl true
  def handle_call({:call, fun, timeout}, _from, state) do
    case state.state do
      :open ->
        if can_reset?(state) do
          new_state = %{state | state: :half_open, failures: 0, success_count: 0}
          do_call(fun, timeout, new_state)
        else
          {:reply, {:error, :circuit_open}, state}
        end

      :half_open ->
        if state.success_count >= 2 do
          new_state = %{state | state: :closed, failures: 0, success_count: 0}
          {:reply, {:ok, :circuit_closed}, new_state}
        else
          do_call(fun, timeout, state)
        end

      :closed ->
        do_call(fun, timeout, state)
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state.state, state}
  end

  defp do_call(fun, _timeout, state) do
    try do
      result = fun.()
      new_state = record_success(state)
      {:reply, {:ok, result}, new_state}
    catch
      _kind, _error ->
        new_state = record_failure(state)
        {:reply, {:error, :circuit_failure}, new_state}
    end
  end

  defp record_success(state) when state.state == :half_open do
    %{state | success_count: state.success_count + 1}
  end

  defp record_success(state) do
    %{state | failures: 0, success_count: 0}
  end

  defp record_failure(state) do
    failures = state.failures + 1

    if failures >= @failure_threshold do
      %{
        state
        | state: :open,
          failures: failures,
          last_failure: System.monotonic_time(:millisecond)
      }
    else
      %{state | failures: failures}
    end
  end

  defp can_reset?(state) do
    if state.last_failure do
      elapsed = System.monotonic_time(:millisecond) - state.last_failure
      elapsed >= @half_open_timeout
    else
      true
    end
  end
end
