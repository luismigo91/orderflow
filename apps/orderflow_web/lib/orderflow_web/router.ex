defmodule OrderflowWeb.Router do
  use OrderflowWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OrderflowWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug OrderflowWeb.Plugs.FetchCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OrderflowWeb.Plugs.RateLimiter
  end

  pipeline :require_auth do
    plug OrderflowWeb.Plugs.RequireAuth
  end

  pipeline :require_chef do
    plug OrderflowWeb.Plugs.RequireAuth
    plug OrderflowWeb.Plugs.RequireRole, :chef
  end

  pipeline :require_admin do
    plug OrderflowWeb.Plugs.RequireAuth
    plug OrderflowWeb.Plugs.RequireRole, :admin
  end

  # Public routes
  scope "/", OrderflowWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", PageController, :login
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete
    live "/track/:id", OrderTrackerLive.Index, :index
    live "/menu/:code", MenuLive.Qr, :index
  end

  # Kitchen routes (chef only)
  scope "/kitchen", OrderflowWeb do
    pipe_through [:browser, :require_chef]

    live "/", KitchenLive.Index, :index
  end

  # Admin routes
  scope "/admin", OrderflowWeb do
    pipe_through [:browser, :require_admin]

    live "/", AdminLive.Dashboard, :index
    live "/users", AdminLive.UserManagement, :index
    live "/products", AdminLive.ProductManagement, :index
    live "/history", AdminLive.OrderHistory, :index
    live "/promotions", AdminLive.Promotions, :index
    live "/reviews", AdminLive.Reviews, :index
    live "/webhooks", AdminLive.Webhooks, :index
    live "/feature-flags", AdminLive.FeatureFlags, :index
    live "/inventory", AdminLive.InventoryAlerts, :index
    live "/audit-log", AdminLive.AuditLog, :index
    live "/analytics", AdminLive.Analytics, :index
    live "/quick-actions", AdminLive.QuickActions, :index
    live "/monitoring", AdminLive.Monitoring, :index
    live "/dashboard-v2", AdminLive.DashboardV2, :index
    live "/tables", AdminLive.Tables, :index
    live "/reservations", AdminLive.Reservations, :index
    live "/loyalty-tiers", AdminLive.LoyaltyTiers, :index
    live "/feedback", AdminLive.Feedback, :index
    live "/kitchen-metrics", AdminLive.KitchenMetrics, :index
    live "/gift-cards", AdminLive.GiftCards, :index
    live "/shifts", AdminLive.Shifts, :index
  end

  # Chat routes
  scope "/chat", OrderflowWeb do
    pipe_through [:browser, :require_auth]

    live "/", ChatLive.Index, :index
  end

  # Map routes
  scope "/map", OrderflowWeb do
    pipe_through [:browser, :require_auth]

    live "/", MapLive.Index, :index
  end

  # API v1 routes
  scope "/api/v1", OrderflowWeb.Api do
    pipe_through :api

    post "/sessions", SessionController, :create
    get "/health", HealthController, :index
    get "/health/detailed", HealthController, :detailed
    get "/docs", ApiDocsController, :index
  end

  # GraphQL
  scope "/graphql" do
    pipe_through :api

    forward "/", Absinthe.Plug, schema: OrderflowWeb.Schema
  end

  scope "/api/v1", OrderflowWeb.Api do
    pipe_through [:api, OrderflowWeb.Plugs.ApiAuth]

    get "/me", SessionController, :me
    get "/orders", OrderController, :index
    get "/orders/:id", OrderController, :show
    post "/orders", OrderController, :create
    patch "/orders/:id/status", OrderController, :update_status
    delete "/orders/:id", OrderController, :delete
    get "/products", ProductController, :index
    get "/products/:id", ProductController, :show
    get "/products/search", SearchController, :search_products
    get "/exports/orders", ExportController, :export_orders
    get "/exports/receipt/:id", ExportController, :export_receipt
    post "/bulk/products", BulkController, :bulk_update_products
    post "/bulk/orders", BulkController, :bulk_archive_orders
    get "/loyalty/tiers", LoyaltyController, :tiers
    get "/loyalty/me", LoyaltyController, :me
    get "/tables", TableController, :index
    post "/tables", TableController, :create
    get "/tables/:id", TableController, :show
    put "/tables/:id", TableController, :update
    get "/reservations", ReservationController, :index
    post "/reservations", ReservationController, :create
    get "/reservations/:id", ReservationController, :show
    put "/reservations/:id", ReservationController, :update
    patch "/reservations/:id/cancel", ReservationController, :cancel
    get "/feedback", FeedbackController, :index
    post "/feedback", FeedbackController, :create
    get "/feedback/stats", FeedbackController, :stats
    get "/gift-cards", GiftCardController, :index
    post "/gift-cards", GiftCardController, :create
    get "/gift-cards/:id", GiftCardController, :show
    post "/gift-cards/redeem", GiftCardController, :redeem
    get "/kitchen/metrics", KitchenMetricsController, :index
    get "/kitchen/metrics/stats", KitchenMetricsController, :stats
    get "/shifts", ShiftController, :index
    post "/shifts", ShiftController, :create
    get "/shifts/:id", ShiftController, :show
    put "/shifts/:id", ShiftController, :update
    get "/qr-menus", QrMenuController, :index
    post "/qr-menus", QrMenuController, :create
    get "/qr-menus/:id", QrMenuController, :show
    get "/qr-menus/:code/svg", QrMenuController, :svg
    post "/orders/:id/split", SplitBillController, :create
    get "/orders/split/:id", SplitBillController, :show
    patch "/orders/split/payments/:payment_id/paid", SplitBillController, :mark_paid
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:orderflow_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OrderflowWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
