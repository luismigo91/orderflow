defmodule OrderflowWeb.Api.HealthController do
  use OrderflowWeb, :controller

  alias Orderflow.Repo

  def index(conn, _params) do
    checks = %{
      database: check_database(),
      oban: check_oban(),
      pubsub: check_pubsub(),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    status = if all_healthy?(checks), do: 200, else: 503

    conn
    |> put_status(status)
    |> json(%{
      status: if(status == 200, do: "healthy", else: "unhealthy"),
      checks: checks
    })
  end

  def detailed(conn, _params) do
    checks = %{
      database: check_database(),
      oban: check_oban(),
      pubsub: check_pubsub(),
      disk: check_disk_space(),
      memory: check_memory(),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    status = if all_healthy?(checks), do: 200, else: 503

    conn
    |> put_status(status)
    |> json(%{
      status: if(status == 200, do: "healthy", else: "unhealthy"),
      version: Application.get_env(:orderflow, :version, "0.1.0"),
      environment: Mix.env() |> to_string(),
      checks: checks
    })
  end

  defp check_database do
    try do
      Repo.query!("SELECT 1")
      %{status: "ok", response_time_ms: measure_db_response()}
    rescue
      _ -> %{status: "error", message: "Database connection failed"}
    end
  end

  defp check_oban do
    try do
      Oban.check_queue(queue: :default)
      %{status: "ok", queues: list_oban_queues()}
    rescue
      _ -> %{status: "error", message: "Oban not running"}
    end
  end

  defp check_pubsub do
    try do
      Phoenix.PubSub.broadcast(Orderflow.PubSub, "health:check", %{ping: true})
      %{status: "ok"}
    rescue
      _ -> %{status: "error", message: "PubSub not available"}
    end
  end

  defp check_disk_space do
    # Simulated
    %{status: "ok", usage_percent: 45}
  end

  defp check_memory do
    memory = :erlang.memory(:total)
    %{status: "ok", used_mb: div(memory, 1024 * 1024)}
  end

  defp measure_db_response do
    start = System.monotonic_time(:millisecond)
    Repo.query!("SELECT 1")
    System.monotonic_time(:millisecond) - start
  end

  defp list_oban_queues do
    Oban.config().queues
    |> Enum.map(fn {name, opts} -> %{name: name, limit: opts[:limit] || opts} end)
  end

  defp all_healthy?(checks) do
    checks
    |> Map.values()
    |> Enum.all?(fn
      %{status: "ok"} -> true
      _ -> false
    end)
  end
end
