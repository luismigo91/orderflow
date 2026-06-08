# Design: add-realtime-kitchen-display

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         apps/orderflow_web/                          │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  LiveViews:                                                      │ │
│  │  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐ │ │
│  │  │ KitchenDisplay   │ │ OrderTracker     │ │ OrderForm        │ │ │
│  │  │ • Orders list    │ │ • Status display │ │ • Create order   │ │ │
│  │  │ • State buttons  │ │ • ETA timer      │ │ • Live items     │ │ │
│  │  │ • Real-time      │ │ • Real-time      │ │ • Live total     │ │ │
│  │  │ • Alerts         │ │ • History        │ │ • Validation     │ │ │
│  │  └──────────────────┘ └──────────────────┘ └──────────────────┘ │ │
│  │  ┌──────────────────┐                                            │ │
│  │  │ OrderflowWeb.Presence                                          │ │
│  │  │ • Track active users                                           │ │
│  │  │ • Display "👨‍🍳 N online"                                       │ │
│  │  └──────────────────┘                                            │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Plugs:                                                          │ │
│  │  • RequireAuth (ensure logged in)                                │ │
│  │  • RequireRole (ensure correct role)                             │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  PubSub:                                                         │ │
│  │  • Topic: "orders:lobby" → all order changes                    │ │
│  │  • Topic: "order:#{id}" → specific order changes               │ │
│  │  • Topic: "presence:lobby" → user presence                     │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## LiveView: KitchenDisplay

### Responsibilities
- Display all orders in `cooking` and `ready` status as a grid
- Show new orders in real-time (without refresh)
- Allow chefs to click "Mark Ready" (cooking → ready)
- Allow chefs to click "Assign for Delivery" (ready → delivering)
- Show timer: how long has the order been in current state?
- Show alert (red border) if cooking > 30 minutes
- Show order items, customer name, phone

### UI Design

```
┌─────────────────────────────────────────────────────────────┐
│  🍳 Cocina                          👨‍🍳 3 online │ 10:45  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐         │
│  │ ⏱️ 04:32     │ │ ⏱️ 02:15     │ │ ⏱️ 00:45     │         │
│  │   #1024      │ │   #1025      │ │   #1026      │         │
│  │  🍳 COOKING  │ │  🍳 COOKING  │ │  ✅ READY    │         │
│  │              │ │              │ │              │         │
│  │  Juan Pérez  │ │  María L.    │ │  Carlos S.   │         │
│  │  📞 555-0123 │ │  📞 555-0456 │ │  📞 555-0789 │         │
│  │              │ │              │ │              │         │
│  │  2x Pizza    │ │  1x Burger   │ │  1x Salad    │         │
│  │  1x Soda     │ │  2x Fries    │ │              │         │
│  │              │ │              │ │              │         │
│  │ [Marcar      │ │ [Marcar      │ │ [Asignar     │         │
│  │  Listo ✅]   │ │  Listo ✅]   │ │  Reparto 📦]│         │
│  └──────────────┘ └──────────────┘ └──────────────┘         │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ ⚠️ PEDIDO #1021 ATASCADO: 45 min en cocina              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```elixir
defmodule OrderflowWeb.KitchenLive.Index do
  use OrderflowWeb, :live_view
  alias Orderflow.Orders
  
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Orderflow.PubSub.subscribe("orders:lobby")
      OrderflowWeb.Presence.track(socket, "kitchen:lobby", %{
        name: socket.assigns.current_user.name,
        role: socket.assigns.current_user.role
      })
    end
    
    orders = Orders.list_orders_by_status([:cooking, :ready])
    
    {:ok, 
      socket
      |> assign(:orders, orders)
      |> assign(:online_users, []),
      layout: {OrderflowWeb.Layouts, :kitchen}  # Full-screen layout
    }
  end
  
  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "order_updated"} = msg, socket) do
    # Refresh orders list
    orders = Orders.list_orders_by_status([:cooking, :ready])
    {:noreply, assign(socket, :orders, orders)}
  end
  
  @impl true
  def handle_event("advance_status", %{"id" => id, "status" => status}, socket) do
    order = Orders.get_order!(id)
    
    case Orders.advance_status(order, String.to_atom(status), socket.assigns.current_user.email) do
      {:ok, _order} ->
        # Broadcast is handled by Orders context
        {:noreply, put_flash(socket, :info, "Pedido #{id} actualizado")}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al actualizar pedido")}
    end
  end
end
```

## LiveView: OrderTracker

### Responsibilities
- Customer-facing view (no auth required)
- Show order by ID or phone number
- Display current status with visual progress bar
- Show estimated time
- Update in real-time (if customer keeps page open)

### UI Design

```
┌─────────────────────────────────────────────────────────────┐
│  📦 OrderFlow Tracker                                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Pedido #1024                                                │
│  Juan Pérez                                                  │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  ✅ Recibido    🍳 En cocina    ⏳ Listo    🚲 En camino  ││
│  │      ●──────────────●────────────────○────────○          ││
│  │              15 min ago                                     ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ⏱️ Tiempo estimado: 12 minutos                             │
│                                                              │
│  📋 Tu pedido:                                               │
│  • 2x Pizza Pepperoni - $24.00                              │
│  • 1x Refresco - $3.00                                      │
│  ──────────────────────────────────────────                 │
│  Total: $27.00                                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## LiveView: OrderForm

### Responsibilities
- Admin creates new orders
- Add/remove items dynamically (live add rows)
- Select product from dropdown (filtered by category)
- Calculate total in real-time
- Validate stock availability

### Implementation

Uses `LiveComponent` for line items:

```elixir
defmodule OrderflowWeb.OrderLive.FormComponent do
  use OrderflowWeb, :live_component
  alias Orderflow.Catalog
  alias Orderflow.Orders
  
  @impl true
  def update(%{order: order} = assigns, socket) do
    changeset = Orders.change_order(order)
    products = Catalog.list_products()
    
    {:ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:products, products)
      |> assign(:total, calculate_total(changeset))
    }
  end
  
  @impl true
  def handle_event("add_item", _, socket) do
    # Add empty line item to changeset
    # ...
  end
  
  @impl true
  def handle_event("remove_item", %{"index" => index}, socket) do
    # Remove line item from changeset
    # ...
  end
  
  @impl true
  def handle_event("validate", %{"order" => params}, socket) do
    changeset = Orders.change_order(socket.assigns.order, params)
    {:noreply, 
      socket
      |> assign(:changeset, changeset)
      |> assign(:total, calculate_total(changeset))
    }
  end
end
```

## Presence

```elixir
defmodule OrderflowWeb.Presence do
  @moduledoc "Track presence of users in the system"
  use Phoenix.Presence,
    otp_app: :orderflow_web,
    pubsub_server: Orderflow.PubSub
end
```

Usage in KitchenDisplay:
- `Presence.track(socket, "kitchen:lobby", meta)`
- `Presence.list("kitchen:lobby")` returns online users
- Updates displayed in real-time

## PubSub Integration

The `Orders` context (from previous change) should broadcast:

```elixir
# In Orderflow.Orders
@topic "orders:lobby"

defp broadcast_order_change(order, event) do
  Phoenix.PubSub.broadcast(Orderflow.PubSub, @topic, %{
    event: event,
    order: order
  })
  
  Phoenix.PubSub.broadcast(Orderflow.PubSub, "order:#{order.id}", %{
    event: event,
    order: order
  })
end
```

## Router Updates

```elixir
# In OrderflowWeb.Router

pipeline :browser do
  # ... existing plugs
  plug OrderflowWeb.Plugs.RequireAuth
end

pipeline :kitchen do
  plug :browser
  plug OrderflowWeb.Plugs.RequireRole, :chef
end

# Public routes (no auth)
scope "/", OrderflowWeb do
  get "/track", OrderTrackerController, :index
  live "/track/:id", OrderTrackerLive.Index
end

# Kitchen routes
scope "/kitchen", OrderflowWeb do
  pipe_through :kitchen
  live "/", KitchenLive.Index
end

# Admin routes
scope "/admin", OrderflowWeb do
  pipe_through :admin
  live "/orders/new", OrderLive.Index, :new
end
```

## Plugs

```elixir
defmodule OrderflowWeb.Plugs.RequireAuth do
  @moduledoc "Ensures user is authenticated"
  import Plug.Conn
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "Debes iniciar sesión")
      |> Phoenix.Controller.redirect(to: "/login")
      |> halt()
    end
  end
end

defmodule OrderflowWeb.Plugs.RequireRole do
  @moduledoc "Ensures user has required role"
  import Plug.Conn
  
  def init(role), do: role
  
  def call(conn, role) do
    user = conn.assigns[:current_user]
    
    if user && user.role == role do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "No tienes permiso")
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end
end
```

## Layouts

- `root.html.heex` — existing, with navigation
- `kitchen.html.heex` — full-screen, no nav, optimized for tablets
- `public.html.heex` — minimal, for tracker (no auth)

## Testing Strategy

- **LiveView tests**: Mount, render, handle events, assert DOM changes
- **PubSub tests**: Assert broadcast is sent on order change
- **Presence tests**: Track and list users
- **Integration tests**: Two LiveView instances receive same broadcast
- **Route tests**: Auth and role guards

## Components

- `OrderflowWeb.OrderComponents.OrderCard` — reusable card for order display
- `OrderflowWeb.OrderComponents.StatusBadge` — colored badge for status
- `OrderflowWeb.OrderComponents.Timer` — elapsed time display
- `OrderflowWeb.OrderComponents.ProgressBar` — tracker progress visualization

## Responsive Design

- Kitchen display: CSS Grid, 3 columns on desktop, 1 on mobile
- Tablet-optimized: buttons are large, text is readable from 2m away
- Dark mode friendly (using Tailwind `dark:` variants)

## Dependencies

No new dependencies needed — all features use built-in Phoenix/LiveView.
- Phoenix.PubSub (already in deps)
- Phoenix.Presence (already in deps)
- Phoenix.LiveView (already in deps)
