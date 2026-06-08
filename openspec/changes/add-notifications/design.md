# Design: add-notifications

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         apps/orderflow/                              │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  OrderNotifier GenServer                                         │ │
│  │  • Subscribes to "orders:lobby"                                  │ │
│  │  • Sends emails on state changes                                 │ │
│  │  • Sends admin alerts for stuck orders                           │ │
│  │  • Uses Orderflow.Mailer (Swoosh)                              │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Alert Scheduler GenServer                                       │ │
│  │  • Runs every 5 minutes                                          │ │
│  │  • Finds stuck orders                                            │ │
│  │  • Broadcasts alerts to admin dashboard                          │ │
│  │  • Uses Orderflow.PubSub                                         │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Email Templates (HEEx)                                          │ │
│  │  • Order confirmed email                                           │ │
│  │  • Order delivering email                                          │ │
│  │  • Order delivered email                                           │ │
│  │  • Admin alert email                                               │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## OrderNotifier GenServer

```elixir
defmodule Orderflow.Notifications.OrderNotifier do
  @moduledoc "Sends notifications based on order state changes"
  use GenServer
  
  alias Orderflow.Orders
  alias Orderflow.Notifications.Emails
  alias Orderflow.Mailer
  
  @topic "orders:lobby"
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    Phoenix.PubSub.subscribe(Orderflow.PubSub, @topic)
    {:ok, %{}}
  end
  
  @impl true
  def handle_info(%{event: "order_updated", order: order}, state) do
    send_notification(order)
    {:noreply, state}
  end
  
  defp send_notification(order) do
    case order.status do
      :cooking ->
        Emails.order_confirmed(order)
        |> Mailer.deliver()
      
      :delivering ->
        Emails.order_on_the_way(order)
        |> Mailer.deliver()
      
      :delivered ->
        Emails.order_delivered(order)
        |> Mailer.deliver()
      
      _ ->
        :ok
    end
  end
end
```

## Alert Scheduler

```elixir
defmodule Orderflow.Alerts.Scheduler do
  @moduledoc "Periodically checks for stuck orders and sends alerts"
  use GenServer
  
  alias Orderflow.Orders
  
  @check_interval :timer.minutes(5)
  @cooking_threshold :timer.minutes(30)
  @pending_threshold :timer.minutes(10)
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    schedule_check()
    {:ok, %{}}
  end
  
  @impl true
  def handle_info(:check, state) do
    check_stuck_orders()
    schedule_check()
    {:noreply, state}
  end
  
  defp check_stuck_orders do
    now = NaiveDateTime.utc_now()
    
    # Check orders stuck in cooking
    Orders.list_orders_by_status(:cooking)
    |> Enum.filter(fn order ->
      time_in_state = NaiveDateTime.diff(now, order.updated_at, :second)
      time_in_state > @cooking_threshold / 1000
    end)
    |> Enum.each(&broadcast_alert(:cooking, &1))
    
    # Check orders stuck in pending
    Orders.list_orders_by_status(:pending)
    |> Enum.filter(fn order ->
      time_in_state = NaiveDateTime.diff(now, order.updated_at, :second)
      time_in_state > @pending_threshold / 1000
    end)
    |> Enum.each(&broadcast_alert(:pending, &1))
  end
  
  defp broadcast_alert(type, order) do
    Phoenix.PubSub.broadcast(
      Orderflow.PubSub,
      "admin:alerts",
      %{type: :stuck_order, order_type: type, order: order}
    )
  end
  
  defp schedule_check do
    Process.send_after(self(), :check, @check_interval)
  end
end
```

## Email Templates

### Order Confirmed Email

```heex
<!-- apps/orderflow_web/lib/orderflow_web/emails/order_confirmed.html.heex -->
<div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
  <h1 style="color: #10b981;">¡Tu pedido está en preparación!</h1>
  
  <p>Hola <%= @order.customer_name %>,</p>
  
  <p>Tu pedido #<%= @order.id %> está siendo preparado en este momento.</p>
  
  <div style="background: #f3f4f6; padding: 20px; border-radius: 8px;">
    <h3>Resumen del pedido:</h3>
    <ul>
      <%= for item <- @order.order_items do %>
        <li><%= item.quantity %>x <%= item.product.name %> - $<%= item.subtotal %></li>
      <% end %>
    </ul>
    <p><strong>Total: $<%= @order.total %></strong></p>
  </div>
  
  <p>Tiempo estimado: <strong>20-30 minutos</strong></p>
  
  <p>Puedes seguir tu pedido en: <a href="<%= @tracker_url %>">Seguir pedido</a></p>
</div>
```

### Order On The Way Email

```heex
<!-- apps/orderflow_web/lib/orderflow_web/emails/order_on_the_way.html.heex -->
<div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
  <h1 style="color: #3b82f6;">¡Tu pedido va en camino!</h1>
  
  <p>Hola <%= @order.customer_name %>,</p>
  
  <p>Tu pedido #<%= @order.id %> ha salido para entrega.</p>
  
  <p>Tiempo estimado de llegada: <strong>15-20 minutos</strong></p>
  
  <p>Seguir pedido: <a href="<%= @tracker_url %>">Seguir pedido</a></p>
</div>
```

### Order Delivered Email

```heex
<!-- apps/orderflow_web/lib/orderflow_web/emails/order_delivered.html.heex -->
<div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
  <h1 style="color: #10b981;">¡Pedido entregado!</h1>
  
  <p>Hola <%= @order.customer_name %>,</p>
  
  <p>Tu pedido #<%= @order.id %> ha sido entregado. ¡Esperamos que disfrutes!</p>
  
  <div style="background: #f3f4f6; padding: 20px; border-radius: 8px;">
    <p><strong>Total: $<%= @order.total %></strong></p>
  </div>
  
  <p>Gracias por elegirnos.</p>
</div>
```

### Admin Alert Email

```heex
<!-- apps/orderflow_web/lib/orderflow_web/emails/admin_alert.html.heex -->
<div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
  <h1 style="color: #ef4444;">⚠️ Alerta: Pedido atascado</h1>
  
  <p>El pedido #<%= @order.id %> lleva más de <%= @threshold %> minutos en estado "<%= @order.status %>".</p>
  
  <div style="background: #fef2f2; padding: 20px; border-radius: 8px; border: 1px solid #fecaca;">
    <p><strong>Cliente:</strong> <%= @order.customer_name %></p>
    <p><strong>Teléfono:</strong> <%= @order.customer_phone %></p>
    <p><strong>Items:</strong></p>
    <ul>
      <%= for item <- @order.order_items do %>
        <li><%= item.quantity %>x <%= item.product.name %></li>
      <% end %>
    </ul>
  </div>
  
  <p><a href="<%= @admin_url %>">Ver en panel de administración</a></p>
</div>
```

## Email Module

```elixir
defmodule Orderflow.Notifications.Emails do
  @moduledoc "Email builders for order notifications"
  
  import Swoosh.Email
  
  def order_confirmed(order) do
    new()
    |> to({order.customer_name, "customer@example.com"})  # Use customer_email if available
    |> from({"OrderFlow", "noreply@orderflow.com"})
    |> subject("Pedido ##{order.id} en preparación")
    |> render_body("order_confirmed.html", order: order, tracker_url: tracker_url(order))
  end
  
  def order_on_the_way(order) do
    new()
    |> to({order.customer_name, "customer@example.com"})
    |> from({"OrderFlow", "noreply@orderflow.com"})
    |> subject("Pedido ##{order.id} en camino")
    |> render_body("order_on_the_way.html", order: order, tracker_url: tracker_url(order))
  end
  
  def order_delivered(order) do
    new()
    |> to({order.customer_name, "customer@example.com"})
    |> from({"OrderFlow", "noreply@orderflow.com"})
    |> subject("Pedido ##{order.id} entregado")
    |> render_body("order_delivered.html", order: order)
  end
  
  def admin_alert(order, type, threshold) do
    new()
    |> to({"Admin", "admin@orderflow.com"})
    |> from({"OrderFlow Alerts", "alerts@orderflow.com"})
    |> subject("⚠️ Pedido ##{order.id} atascado en #{order.status}")
    |> render_body("admin_alert.html", 
      order: order, 
      type: type, 
      threshold: threshold,
      admin_url: admin_url(order)
    )
  end
  
  defp tracker_url(order) do
    OrderflowWeb.Router.Helpers.order_tracker_url(OrderflowWeb.Endpoint, :index, order.id)
  end
  
  defp admin_url(order) do
    OrderflowWeb.Router.Helpers.admin_dashboard_url(OrderflowWeb.Endpoint, :index)
  end
end
```

## Swoosh Configuration

Already configured in `config/config.exs`:
```elixir
config :orderflow, Orderflow.Mailer, adapter: Swoosh.Adapters.Local
```

In `config/test.exs`:
```elixir
config :orderflow, Orderflow.Mailer, adapter: Swoosh.Adapters.Test
```

In `config/runtime.exs` (production):
```elixir
config :orderflow, Orderflow.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: System.get_env("SMTP_HOST"),
  username: System.get_env("SMTP_USER"),
  password: System.get_env("SMTP_PASS"),
  port: String.to_integer(System.get_env("SMTP_PORT", "587")),
  tls: :always
```

## Directory Structure

```
apps/orderflow/lib/orderflow/notifications/
├── order_notifier.ex
├── alert_scheduler.ex
└── emails.ex

apps/orderflow_web/lib/orderflow_web/emails/
├── order_confirmed.html.heex
├── order_on_the_way.html.heex
├── order_delivered.html.heex
└── admin_alert.html.heex
```

## Testing Strategy

- **GenServer tests**: Verify it starts, subscribes, handles broadcasts
- **Email tests**: Assert emails are sent using `Swoosh.TestAssertions`
- **Scheduler tests**: Verify it checks for stuck orders and broadcasts
- **Integration tests**: Create order → advance status → assert email sent
- **Email template tests**: Verify HTML renders correctly

## Admin Alert Integration

The AdminDashboard LiveView should listen to `"admin:alerts"` topic:

```elixir
def handle_info(%{type: :stuck_order, order: order}, socket) do
  alerts = [order | socket.assigns.alerts]
  {:noreply, assign(socket, :alerts, alerts)}
end
```

## Dependencies

- `{:swoosh, "~> 1.16"}` — already present
- `{:gen_smtp, "~> 1.0"}` — optional, for SMTP support in production
- No new dependencies needed for development

## Notes

- Email addresses: For demo purposes, use customer_phone as identifier or a placeholder email. In production, add `customer_email` to orders.
- Dev mailbox: Accessible at `/dev/mailbox` when `dev_routes` is enabled.
- Templates: Use inline CSS for email compatibility (no external stylesheets).
- Admin alerts: Use `Phoenix.PubSub` to broadcast to admin dashboard, not just email.
- OrderNotifier should handle errors gracefully (don't crash if email fails).
- Consider adding `{:gen_smtp, "~> 1.0"}` to `orderflow/mix.exs` for production SMTP support.
