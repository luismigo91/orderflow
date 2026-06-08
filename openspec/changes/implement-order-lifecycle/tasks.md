# Tasks: implement-order-lifecycle

## 1. Create Migrations
- [ ] Create migration: `create_orders` (customer_name, customer_phone, total, status, notes, cancel_reason, estimated_ready_at, estimated_delivery_at, user_id, assigned_user_id, timestamps)
- [ ] Create migration: `create_order_items` (order_id, product_id, quantity, unit_price, subtotal, notes, timestamps)
- [ ] Create migration: `create_order_status_logs` (order_id, from_status, to_status, changed_by, reason, timestamps)
- [ ] Create migration: `add_api_token_to_users` (api_token, unique, nullable)
- [ ] Add indexes: `orders.status`, `orders.user_id`, `orders.assigned_user_id`, `order_items.order_id`, `order_items.product_id`, `order_status_logs.order_id`
- [ ] Run `mix ecto.migrate` to verify

## 2. Implement OrderFSM
- [ ] Create `apps/orderflow/lib/orderflow/orders/order_fsm.ex`
- [ ] Define `@transitions` map with all allowed transitions
- [ ] Implement `allowed_transitions/1`
- [ ] Implement `transition_allowed?/2`
- [ ] Implement `transition!/4` (validates and returns result or raises)
- [ ] Add `@moduledoc` with transition diagram

## 3. Implement Schema: Order
- [ ] Create `apps/orderflow/lib/orderflow/orders/order.ex`
- [ ] Define schema with all fields
- [ ] Add `changeset/2` for create/update
- [ ] Add `status_changeset/2` for status-only updates
- [ ] Add validations: customer_name required, customer_phone format, total positive
- [ ] Add `calculate_total/1` function
- [ ] Add `estimated_ready_at` and `estimated_delivery_at` helpers

## 4. Implement Schema: OrderItem
- [ ] Create `apps/orderflow/lib/orderflow/orders/order_item.ex`
- [ ] Define schema with quantity, unit_price, subtotal
- [ ] Add `changeset/2` with validations: quantity > 0, unit_price > 0
- [ ] Add `calculate_subtotal/1` function
- [ ] Add `cast_assoc` for nested creation

## 5. Implement Schema: OrderStatusLog
- [ ] Create `apps/orderflow/lib/orderflow/orders/order_status_log.ex`
- [ ] Define schema with from_status, to_status, changed_by, reason
- [ ] Add `changeset/2` with validations: from_status != to_status, reason required for cancelled
- [ ] Add `create_changeset/4` helper

## 6. Implement Orders Context
- [ ] Create `apps/orderflow/lib/orderflow/orders/orders.ex`
- [ ] Implement `list_orders/0`
- [ ] Implement `list_orders_by_status/1` and `list_orders_by_status/2`
- [ ] Implement `get_order!/1`
- [ ] Implement `get_order_with_items/1` (preload items + products)
- [ ] Implement `create_order/2` with nested items (Ecto.Multi)
- [ ] Implement `update_order/2`
- [ ] Implement `delete_order/1`
- [ ] Implement `advance_status/4` (uses FSM + Multi + log + stock)
- [ ] Implement `cancel_order/3` (specific cancel logic with reason)
- [ ] Implement `assign_rider/2`
- [ ] Implement `calculate_total/1`
- [ ] Implement `list_status_logs/1`
- [ ] Implement `log_status_change/5` (private helper)
- [ ] Add `PubSub.broadcast` after successful transitions (preparing for real-time)

## 7. Stock Integration
- [ ] On `confirmed → cooking`: call `Catalog.decrement_stock/2` for each item
- [ ] On `cancelled` (from cooking): call `Catalog.restore_stock/2` for each item
- [ ] Handle `Ecto.Multi` failures when stock is insufficient
- [ ] Add error handling: `{:error, :insufficient_stock, product_name}`
- [ ] Test stock edge cases

## 8. Update Seeds
- [ ] Update `apps/orderflow/priv/repo/seeds.exs`
- [ ] Create sample orders with items
- [ ] Create sample status logs
- [ ] Ensure seeds demonstrate all order statuses
- [ ] Run `mix ecto.reset` to verify

## 9. Write Tests
- [ ] Create `apps/orderflow/test/orderflow/orders_test.exs`
  - [ ] Test `list_orders/0`
  - [ ] Test `list_orders_by_status/1`
  - [ ] Test `get_order!/1` and `get_order_with_items/1`
  - [ ] Test `create_order/2` with valid nested items
  - [ ] Test `create_order/2` with invalid items (negative quantity)
  - [ ] Test `update_order/2`
  - [ ] Test `delete_order/1`
  - [ ] Test `advance_status/4` with valid transitions
  - [ ] Test `advance_status/4` with invalid transitions (should raise or return error)
  - [ ] Test `advance_status/4` from confirmed to cooking decrements stock
  - [ ] Test `advance_status/4` from cooking to cancelled restores stock
  - [ ] Test `cancel_order/3` with reason
  - [ ] Test `assign_rider/2`
  - [ ] Test `calculate_total/1` matches sum of subtotals
  - [ ] Test `list_status_logs/1` returns ordered logs
  - [ ] Test order creation fails if product doesn't exist
  - [ ] Test order creation fails if insufficient stock
  - [ ] Test FSM: `allowed_transitions/1` returns correct list
  - [ ] Test FSM: `transition_allowed?/2` for valid and invalid
  - [ ] Test FSM: `transition!/4` raises on invalid
  - [ ] Test complete lifecycle: pending → confirmed → cooking → ready → delivering → delivered
  - [ ] Test status log is created on every transition

## 10. Quality Gate
- [ ] Run `mix compile --warnings-as-errors`
- [ ] Run `mix deps.unlock --unused`
- [ ] Run `mix format`
- [ ] Run `mix test` (all pass)
- [ ] Run `mix precommit` (all pass)
- [ ] Manual verification: `iex -S mix` → create order → advance through lifecycle
- [ ] Manual verification: `Orderflow.Orders.list_orders_by_status(:cooking)` returns seeded data

## 11. Documentation
- [ ] Add `@moduledoc` to `Orderflow.Orders` context
- [ ] Add `@moduledoc` to `Orderflow.Orders.OrderFSM`
- [ ] Add doc comments for complex functions (create_order, advance_status)
- [ ] Update `apps/orderflow/README.md` with Orders context description
- [ ] Add FSM transition diagram to design.md (if not already)

## 12. API Token Preparation
- [ ] Add `api_token` field to `User` schema
- [ ] Add `generate_api_token/1` in Accounts context
- [ ] Add `get_user_by_api_token/1` in Accounts context
- [ ] Test API token generation
- [ ] Update seeds to include api_token for users
