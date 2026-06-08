defmodule ElixirTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirTest.Repo,
      {DNSCluster, query: Application.get_env(:elixir_test, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirTest.PubSub}
      # Start a worker by calling: ElixirTest.Worker.start_link(arg)
      # {ElixirTest.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ElixirTest.Supervisor)
  end
end
