defmodule Orderflow.Repo do
  use Ecto.Repo,
    otp_app: :orderflow,
    adapter: Ecto.Adapters.Postgres
end
