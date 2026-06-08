defmodule Orderflow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Orderflow.Repo,
      {DNSCluster, query: Application.get_env(:orderflow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Orderflow.PubSub},
      {Oban, Application.fetch_env!(:orderflow, Oban)},
      Orderflow.Metrics.Collector,
      Orderflow.Notifications.OrderNotifier,
      Orderflow.Alerts.Scheduler,
      Orderflow.Pipelines.OrderProducer,
      Orderflow.Pipelines.OrderProcessor,
      Orderflow.Cache,
      Orderflow.Monitoring.Alerts,
      Orderflow.CircuitBreaker
      # Start a worker by calling: Orderflow.Worker.start_link(arg)
      # {Orderflow.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Orderflow.Supervisor)
  end
end
