# Design: build-admin-dashboard

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         apps/orderflow_web/                          │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  LiveViews:                                                      │ │
│  │  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐ │ │
│  │  │ AdminDashboard   │ │ UserManagement   │ │ ProductManagement│ │ │
│  │  │ • Metrics cards  │ │ • User list      │ │ • Product list   │ │ │
│  │  │ • Charts (CSS)   │ │ • Inline edit    │ │ • Stock edit     │ │ │
│  │  │ • Active orders  │ │ • Role badges    │ │ • Category filter│ │ │
│  │  │ • Revenue        │ │ • Activate       │ │ • Toggle active  │ │ │
│  │  └──────────────────┘ └──────────────────┘ └──────────────────┘ │ │
│  │  ┌──────────────────┐                                            │ │
│  │  │ OrderHistory     │                                            │ │
│  │  │ • Filter by status│                                           │ │
│  │  │ • Date range      │                                           │ │
│  │  │ • Sort by date    │                                           │ │
│  │  │ • Pagination       │                                          │ │
│  │  └──────────────────┘                                            │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │  Background:                                                     │ │
│  │  • MetricsCollector GenServer                                    │ │
│  │  • Orderflow.Metrics.Cache (ETS)                                 │ │
│  │  • Periodic recalculation (every 5 min)                          │ │
│  │  • PubSub-triggered updates                                      │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## MetricsCollector GenServer

```elixir
defmodule Orderflow.Metrics.Collector do
  @moduledoc "Collects and caches dashboard metrics"
  use GenServer
  
  @table :metrics_cache
  @tick_interval :timer.minutes(5)
  
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(_opts) do
    :ets.new(@table, [:set, :public, :named_table])
    schedule_tick()
    {:ok, %{}}
  end
  
  @impl true
  def handle_info(:tick, state) do
    metrics = calculate_metrics()
    :ets.insert(@table, {:dashboard, metrics})
    schedule_tick()
    {:noreply, state}
  end
  
  defp calculate_metrics do
    today = Date.utc_today()
    
    %{
      orders_today: Orders.count_orders_by_date(today),
      revenue_today: Orders.sum_revenue_by_date(today),
      orders_this_week: Orders.count_orders_by_week(today),
      revenue_this_week: Orders.sum_revenue_by_week(today),
      avg_order_time: Orders.avg_order_time(today),
      orders_by_status: Orders.count_by_status(today),
      active_orders: Orders.count_active_orders()
    }
  end
  
  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end
  
  def get_dashboard_metrics do
    case :ets.lookup(@table, :dashboard) do
      [{:dashboard, metrics}] -> metrics
      [] -> calculate_metrics()
    end
  end
  
  def refresh_metrics do
    send(__MODULE__, :tick)
  end
end
```

## AdminDashboard LiveView

### UI Design

```
┌─────────────────────────────────────────────────────────────┐
│  📊 Panel de Administración     👤 Admin │ 10:45 AM           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │ 12      │ │ $456.00 │ │ 23 min  │ │ 5       │           │
│  │ Pedidos │ │ Ingresos│ │ Promedio│ │ Activos │           │
│  │  Hoy    │ │   Hoy   │ │  tiempo │ │  ahora  │           │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘           │
│                                                              │
│  ┌─────────────────────┐ ┌─────────────────────────────┐    │
│  │  Pedidos por Estado │ │  Actividad de la Semana    │    │
│  │  ┌──────────┐       │ │  ┌─────────────────────┐    │    │
│  │  │  ██████  │ 8     │ │  │                     │    │    │
│  │  │  ████    │ 5     │ │  │     ▄▄▄▄▄▄▄▄▄       │    │    │
│  │  │  ██      │ 2     │ │  │   ▄▄▄▄▄▄▄▄▄▄▄▄▄     │    │    │
│  │  │  █       │ 1     │ │  │ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄   │    │    │
│  │  │          │       │ │  │                     │    │    │
│  │  │ Cooking  │ Ready │ │  │  Lun Mar Mie Jue Vie│    │    │
│  │  │  8       │ 5     │ │  │  12   8   15  10  12│    │    │
│  │  └──────────┘       │ │  └─────────────────────┘    │    │
│  └─────────────────────┘ └─────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Pedidos Activos                                          ││
│  │  ┌────────┬────────┬────────┬────────┬────────┐         ││
│  │  │ #1024  │ #1025  │ #1026  │ #1027  │ #1028  │         ││
│  │  │ Juan P │ María  │ Carlos │ Ana    │ Pedro  │         ││
│  │  │ Cooking│ Ready  │ Deliv  │ Pend   │ Conf   │         ││
│  │  └────────┴────────┴────────┴────────┴────────┘         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```elixir
defmodule OrderflowWeb.AdminLive.Dashboard do
  use OrderflowWeb, :live_view
  alias Orderflow.Metrics
  
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Orderflow.PubSub.subscribe("orders:lobby")
    end
    
    metrics = Metrics.Collector.get_dashboard_metrics()
    active_orders = Orderflow.Orders.list_active_orders()
    
    {:ok,
      socket
      |> assign(:metrics, metrics)
      |> assign(:active_orders, active_orders)
    }
  end
  
  @impl true
  def handle_info(%{event: "order_updated"}, socket) do
    # Refresh metrics and active orders
    metrics = Metrics.Collector.get_dashboard_metrics()
    active_orders = Orderflow.Orders.list_active_orders()
    
    {:noreply,
      socket
      |> assign(:metrics, metrics)
      |> assign(:active_orders, active_orders)
    }
  end
end
```

## UserManagement LiveView

### Features
- Table of users with columns: name, email, role, active, actions
- Inline role editing with dropdown
- Toggle active/inactive
- Create new user with modal
- Search/filter by name or email
- Role badges (admin=red, chef=orange, rider=blue, customer=green)

### UI Design
```
┌─────────────────────────────────────────────────────────────┐
│  👥 Gestión de Usuarios                                       │
├─────────────────────────────────────────────────────────────┤
│  [Buscar por nombre...]    [Filtrar por rol ▼] [+ Nuevo]   │
│                                                              │
│  ┌────────┬────────┬────────┬────────┬────────┐          │
│  │ Nombre │ Email  │ Rol    │ Activo │ Acción │          │
│  ├────────┼────────┼────────┼────────┼────────┤          │
│  │ Admin  │ a@...  │ 🔴 Admin│   ✅   │ [Edit] │          │
│  │ Chef1  │ c@...  │ 🟠 Chef │   ✅   │ [Edit] │          │
│  │ Rider1 │ r@...  │ 🔵 Rider│   ❌   │ [Edit] │          │
│  └────────┴────────┴────────┴────────┴────────┘          │
│                                                              │
│  Página 1 de 3    [Anterior] [1] [2] [3] [Siguiente]      │
└─────────────────────────────────────────────────────────────┘
```

## ProductManagement LiveView

### Features
- Table of products with columns: name, category, price, stock, active
- Inline stock editing (number input)
- Toggle active/inactive
- Create new product with modal
- Filter by category
- Sort by price, stock, name
- Stock indicator (green > 10, yellow 5-10, red < 5)

### UI Design
```
┌─────────────────────────────────────────────────────────────┐
│  📦 Gestión de Productos                                      │
├─────────────────────────────────────────────────────────────┤
│  [Buscar...]    [Categoría ▼]    [+ Nuevo Producto]        │
│                                                              │
│  ┌────────┬────────┬────────┬────────┬────────┐             │
│  │ Nombre │ Categ  │ Precio │ Stock  │ Activo │             │
│  ├────────┼────────┼────────┼────────┼────────┤             │
│  │ Pizza  │ Platos │ $12.00 │ 🟢 24  │   ✅   │             │
│  │ Burger │ Platos │ $10.00 │ 🟡 8   │   ✅   │             │
│  │ Soda   │ Bebidas│ $3.00  │ 🔴 2   │   ❌   │             │
│  └────────┴────────┴────────┴────────┴────────┘             │
│                                                              │
│  Stock: 🟢 OK  🟡 Bajo  🔴 Crítico                            │
└─────────────────────────────────────────────────────────────┘
```

## OrderHistory LiveView

### Features
- Searchable, filterable, sortable list of all orders
- Filter by: status (multi-select), date range (today, week, month, custom)
- Sort by: created_at, total, status
- Pagination (manual with offset/limit)
- Show order details inline or modal
- Export to CSV (optional)

### UI Design
```
┌─────────────────────────────────────────────────────────────┐
│  📜 Historial de Pedidos                                      │
├─────────────────────────────────────────────────────────────┤
│  [Buscar # o nombre...]                                     │
│  Estado: [✅ Todas] [Cooking] [Ready] [Delivered] [Pend]    │
│  Fecha: [Hoy] [Semana] [Mes] [Custom]                       │
│  Ordenar: [Fecha ▼]                                         │
│                                                              │
│  ┌────────┬────────┬────────┬────────┬────────┬────────┐  │
│  │ #      │ Cliente│ Estado │ Total  │ Fecha  │ Ver    │  │
│  ├────────┼────────┼────────┼────────┼────────┼────────┤  │
│  │ 1024   │ Juan   │ Deliv  │ $27.00 │ 10:30  │ [👁]   │  │
│  │ 1023   │ María  │ Cancel │ $15.00 │ 09:45  │ [👁]   │  │
│  │ 1022   │ Carlos │ Ready  │ $42.00 │ 09:15  │ [👁]   │  │
│  └────────┴────────┴────────┴────────┴────────┴────────┘  │
│                                                              │
│  Página 1 de 10   [Anterior] [1] [2] [3] ... [10] [▶]    │
│  Total: 234 pedidos encontrados                              │
└─────────────────────────────────────────────────────────────┘
```

## Metrics Queries

Add to `Orderflow.Orders` context:

```elixir
def count_orders_by_date(date) do
  from(o in Order, where: fragment("?::date", o.inserted_at) == ^date)
  |> Repo.aggregate(:count)
end

def sum_revenue_by_date(date) do
  from(o in Order, where: fragment("?::date", o.inserted_at) == ^date)
  |> Repo.aggregate(:sum, :total)
end

def count_by_status(date) do
  from(o in Order, where: fragment("?::date", o.inserted_at) == ^date)
  |> group_by([o], o.status)
  |> select([o], {o.status, count(o.id)})
  |> Repo.all()
end

def avg_order_time(date) do
  from(o in Order,
    where: fragment("?::date", o.inserted_at) == ^date,
    where: o.status in [:ready, :delivering, :delivered]
  )
  |> select([o], avg(fragment("EXTRACT(EPOCH FROM (? - ?))", o.updated_at, o.inserted_at)))
  |> Repo.one()
end
```

## Layout and Components

- `admin.html.heex` — sidebar layout with navigation
  - Sidebar: Dashboard, Usuarios, Productos, Historial, Cocina (link)
  - Top bar: Logo, notifications, user menu
  - Content area: main content
- `AdminComponents` — reusable dashboard components
  - `metric_card/1` — card with icon, number, label
  - `status_bar/1` — horizontal bar chart (CSS-based)
  - `data_table/1` — sortable table with pagination
  - `filter_bar/1` — filter inputs with apply/clear
  - `modal/1` — reusable modal container
  - `badge/1` — colored badge for roles/status

## Router Updates

```elixir
scope "/admin", OrderflowWeb do
  pipe_through [:browser, :admin]
  
  live "/", AdminLive.Dashboard, :index
  live "/users", AdminLive.UserManagement, :index
  live "/users/new", AdminLive.UserManagement, :new
  live "/users/:id/edit", AdminLive.UserManagement, :edit
  live "/products", AdminLive.ProductManagement, :index
  live "/products/new", AdminLive.ProductManagement, :new
  live "/products/:id/edit", AdminLive.ProductManagement, :edit
  live "/history", AdminLive.OrderHistory, :index
end
```

## Testing Strategy

- **LiveView tests**: Dashboard renders, filters work, pagination works
- **GenServer tests**: MetricsCollector starts, calculates, caches
- **Query tests**: Aggregation queries return correct results
- **Integration tests**: Dashboard updates when order changes
- **Auth tests**: Non-admin users redirected from admin routes

## Responsive Design

- Desktop: Sidebar + main content (standard admin layout)
- Tablet: Sidebar collapses to hamburger menu
- Mobile: Stacked cards instead of table, filters in modal

## Dependencies

No new dependencies — all queries use standard Ecto.
- Pagination: manual implementation with `offset`/`limit`
- Charts: CSS-based bar charts (no JS library needed for simple bars)
- Sorting: Ecto query composition with `order_by`

## Optional: Flop

If pagination/filtering gets complex, add `{:flop, "~> 0.20"}` for declarative query composition.
