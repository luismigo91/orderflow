# Proposal: implement-order-lifecycle

## Context

The domain base (`scaffold-orderflow-domain`) provides Users, Categories, and Products. Now we need the core business entity: **Orders** with a lifecycle managed by a Finite State Machine.

## Scope

### Included

1. **Schema `Order`** with FSM states:
   - `pending` → `confirmed` → `cooking` → `ready` → `delivering` → `delivered`
   - `cancelled` terminal state (from `pending` or `confirmed` only)
2. **Schema `OrderItem`** (belongs to Order and Product)
3. **Schema `OrderStatusLog`** (audit trail of every state change)
4. **Context `Orders`** with full CRUD and lifecycle management
5. **OrderFSM** module: validates transitions, triggers side effects (stock decrement, notifications)
6. **Business rules:**
   - Cannot cancel after `cooking`
   - Auto-calculate total from items
   - Decrement stock on `confirmed` → `cooking`
   - Restore stock on `cancelled`
   - Log every transition
7. **Tests** for FSM, context, and business rules

### Excluded

- Real-time UI updates (Change: `add-realtime-kitchen-display`)
- API endpoints (Change: `expose-rest-api`)
- Notifications (Change: `add-notifications`)
- Dashboard metrics (Change: `build-admin-dashboard`)

## Success Criteria

- [ ] Can create an order with items
- [ ] Can progress through the full lifecycle
- [ ] Invalid transitions are rejected
- [ ] Stock is decremented/restored correctly
- [ ] StatusLog records every transition
- [ ] All tests pass
- [ ] `mix precommit` passes

## Technical Notes

- `Order` fields: `customer_name`, `customer_phone`, `total`, `status`, `notes`, `user_id` (FK to admin who created it)
- `OrderItem` fields: `order_id`, `product_id`, `quantity`, `unit_price`, `subtotal`
- `OrderStatusLog` fields: `order_id`, `from_status`, `to_status`, `changed_by`, `changed_at`, `reason`
- FSM module: `Orderflow.Orders.OrderFSM` with `transition/3` and `allowed_transitions/1`
- Use `Ecto.Multi` for atomic transitions (update order + create log + update stock)
