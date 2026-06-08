defmodule Orderflow.Webhooks.Retry do
  @moduledoc """
  Retry logic for webhooks with exponential backoff.
  """
  @max_retries 5
  # 1 second
  @base_delay 1000

  @doc """
  Calculate next retry delay using exponential backoff.
  """
  def next_retry_delay(attempt) when attempt < @max_retries do
    (@base_delay * :math.pow(2, attempt)) |> round()
  end

  def next_retry_delay(_), do: nil

  @doc """
  Should retry based on status code.
  """
  def should_retry?(status_code) when is_integer(status_code) do
    status_code >= 500 or status_code in [408, 429, 0]
  end

  def should_retry?(_), do: true
end
