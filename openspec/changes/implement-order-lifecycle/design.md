# Design: implement-order-lifecycle

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    apps/orderflow/                           │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Context: Orders                                         │ │
│  │  • Order schema (FSM states)                            │ │
│  │  • OrderItem schema (line items)                        │ │
│  │  • OrderStatusLog schema (audit trail)                   │ │
│  │  • OrderFSM (state machine logic)                      │ │
│  │  • Order calculations (totals, subtotals)              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  Integration:                                                 │
│  • Uses Catalog.decrement_stock/2 on cooking transition     │
│  • Uses Catalog.restore_stock/2 on cancelled transition      │
│  • Uses PubSub for broadcasting (preparing for real-time)   │
│  • Uses Accounts to track who changed the order             │
└─────────────────────────────────────────────────────────────┘
```

## Schema Designs

### Order

```elixir
schema "orders" do
  field :customer_name, :string
  field :customer_phone, :string
  field :total, :decimal, precision: 10, scale: 2
  field :status, Ecto.Enum,
    values: [:pending, :confirmed, :cooking, :ready, :delivering, :delivered, :cancelled],
    default: :pending
  field :notes, :string
  field :cancel_reason, :string
  field :estimated_ready_at, :naive_datetime
  field :estimated_delivery_at, :naive_datetime
  
  belongs_to :user, Orderflow.Accounts.User  # who created/confirmed
  belongs_to :assigned_user, Orderflow.Accounts.User  # rider
  
  has_many :order_items, Orderflow.Orders.OrderItem
  has_many :status_logs, Orderflow.Orders.OrderStatusLog
  
  timestamps()
end
```

### OrderItem

```elixir
schema "order_items" do
  field :quantity, :integer, default: 1
  field :unit_price, :decimal, precision: 10, scale: 2
  field :subtotal, :decimal, precision: 10, scale: 2
  field :notes, :string
  
  belongs_to :order, Orderflow.Orders.Order
  belongs_to :product, Orderflow.Catalog.Product
  
  timestamps()
end
```

### OrderStatusLog

```elixir
schema "order_status_logs" do
  field :from_status, Ecto.Enum,
    values: [:pending, :confirmed, :cooking, :ready, :delivering, :delivered, :cancelled]
  field :to_status, Ecto.Enum,
    values: [:pending, :confirmed, :cooking, :ready, :delivering, :delivered, :cancelled]
  field :changed_by, :string  # user email or "system"
  field :reason, :string
  
  belongs_to :order, Orderflow.Orders.Order
  
  timestamps()
end
```

## Finite State Machine

```
┌─────────────────────────────────────────────────────────────┐
│                    OrderFSM Transitions                      │
│                                                              │
│  pending       ──▶ confirmed      │ by: admin/chef        │
│  confirmed     ──▶ cooking        │ by: chef               │
│  confirmed     ──▶ cancelled      │ by: admin (reason req) │
│  pending       ──▶ cancelled      │ by: admin/customer     │
│  cooking       ──▶ ready         │ by: chef               │
│  ready         ──▶ delivering    │ by: rider (auto-assign) │
│  delivering    ──▶ delivered   │ by: rider              │
│  delivering    ──▶ cancelled     │ by: admin (rare, reason)│
│                                                              │
│  Forbidden transitions:                                       │
│  • cooking → cancelled (requires admin override)             │
│  • ready → cancelled (blocked completely)                   │
│  • delivered → any (terminal state)                         │
│  • cancelled → any (terminal state)                        │
└─────────────────────────────────────────────────────────────┘
```

### OrderFSM Module

```elixir
defmodule Orderflow.Orders.OrderFSM do
  @moduledoc "Finite State Machine for Order lifecycle"
  
  @transitions %{
    pending: [:confirmed, :cancelled],
    confirmed: [:cooking, :cancelled],
    cooking: [:ready],
    ready: [:delivering],
    delivering: [:delivered],
    delivered: [],
    cancelled: []
  }
  
  def allowed_transitions(status) do
    Map.get(@transitions, status, [])
  end
  
  def transition_allowed?(from, to) do
    to in allowed_transitions(from)
  end
  
  def transition!(order, to_status, changed_by, reason \\ nil) do
    if transition_allowed?(order.status, to_status) do
      # Returns :ok or raises
      # Actual transaction handled by Orders context
    else
      raise "Invalid transition: #{order.status} → #{to_status}"
    end
  end
end
```

## Context API

### Orders

```elixir
Orders.list_orders()
Orders.list_orders_by_status(status)
Orders.list_orders_by_status(status, opts)  # older_than: minutes
Orders.get_order!(id)
Orders.get_order_with_items(id)
Orders.create_order(attrs, user_id)
Orders.update_order(order, attrs)
Orders.delete_order(order)

Orders.advance_status(order, to_status, changed_by, reason \\ nil)
Orders.cancel_order(order, reason, changed_by)
Orders.assign_rider(order, rider_id)
Orders.calculate_total(order)

Orders.list_status_logs(order_id)
Orders.log_status_change(order, from, to, changed_by, reason)
```

## Business Rules

1. **Stock Management**
   - On `confirmed → cooking`: decrement stock for each product
   - On `cancelled` (from pending/confirmed): no stock change
   - On `cancelled` (from cooking/delivering): restore stock
   - On `cancelled` (from ready): not allowed (no stock to restore)

2. **Auto-calculation**
   - `unit_price` is set from product.price at creation time
   - `subtotal = quantity * unit_price`
   - `total = sum of all subtotals`

3. **Estimation**
   - `estimated_ready_at` set on `confirmed` (now + 20 min)
   - `estimated_delivery_at` set on `ready` (now + 30 min)

4. **Audit Trail**
   - Every transition creates a `OrderStatusLog`
   - `changed_by` records the user who made the change
   - `reason` required for `cancelled`

## Migration Strategy

1. Create `orders` table
2. Create `order_items` table (FK to orders and products)
3. Create `order_status_logs` table (FK to orders)
4. Add `api_token` to `users` table (for API authentication in future change)

## Directory Structure

```
apps/orderflow/lib/orderflow/orders/
├── order.ex
├── order_item.ex
├── order_status_log.ex
├── order_fsm.ex
└── orders.ex

apps/orderflow/test/orderflow/
└── orders_test.exs
```

## Transaction Safety

All status transitions use `Ecto.Multi`:

```elixir
Ecto.Multi.new()
|> Ecto.Multi.update(:order, order_changeset)
|> Ecto.Multi.insert(:log, status_log_changeset)
|> Ecto.Multi.run(:stock, fn _repo, _changes ->
  if to_status == :cooking, do: decrement_stock(order), else: {:ok, nil}
end)
|> Repo.transaction()
```

## Testing Strategy

- **Unit tests**: OrderFSM transition rules
- **Context tests**: Full CRUD, status transitions, stock changes
- **Edge cases**: Invalid transitions, stock depletion, concurrent updates
- **Integration**: Order creation with items, total calculation

## Dependencies

- Reuses `Catalog` context for stock management
- Reuses `Accounts` context for user references
- Prepares for `PubSub` broadcasting (added in next change)
