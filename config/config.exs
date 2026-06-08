# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :orderflow,
  ecto_repos: [Orderflow.Repo]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :orderflow, Orderflow.Mailer, adapter: Swoosh.Adapters.Local

config :orderflow_web,
  ecto_repos: [Orderflow.Repo],
  generators: [context_app: :orderflow]

# Configures the endpoint
config :orderflow_web, OrderflowWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: OrderflowWeb.ErrorHTML, json: OrderflowWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Orderflow.PubSub,
  live_view: [signing_salt: "ni4CLFyP"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  orderflow_web: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../apps/orderflow_web/assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  orderflow_web: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("../apps/orderflow_web", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Oban configuration
config :orderflow, Oban,
  repo: Orderflow.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", Orderflow.Workers.OrderScheduler},
       {"0 * * * *", Orderflow.Workers.CalculateMetrics},
       {"0 2 * * *", Orderflow.Workers.ArchiveOldOrders}
     ]}
  ],
  queues: [default: 10, emails: 5, metrics: 2, webhooks: 5]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
