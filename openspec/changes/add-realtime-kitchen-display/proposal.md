# Proposal: add-realtime-kitchen-display

## Context

Orders exist in the database with a FSM. Now we need the **real-time experience**: the kitchen staff sees orders appear instantly, and the admin sees who's online.

## Scope

### Included

1. **LiveView `KitchenDisplay`** — full-screen grid showing orders in `cooking` and `ready` status
   - Cards with order number, items, timer, status
   - Buttons to advance state: `cooking → ready`, `ready → delivering`
   - New orders appear in real-time via PubSub
   - Visual alerts when orders are stuck > 30 min
2. **LiveView `OrderTracker`** — customer-facing view to track order status
   - Shows current status and estimated time
   - Updates in real-time without refresh
3. **PubSub integration** — `Phoenix.PubSub` broadcasts on every order state change
   - Topic: `"orders:lobby"` for all order updates
   - Topic: `"order:#{id}"` for specific order updates
4. **Presence** — track active users in the kitchen
   - Display "👨‍🍳 3 cocineros online" in the dashboard
   - `OrderflowWeb.Presence` module
5. **LiveView `OrderForm`** — create new orders with live validation
   - Add/remove items dynamically
   - Calculate total in real-time
6. **Tests** — LiveView tests using `OrderflowWeb.ConnCase` and `Phoenix.LiveViewTest`

### Excluded

- Admin dashboard metrics (Change: `build-admin-dashboard`)
- API endpoints (Change: `expose-rest-api`)
- Email notifications (Change: `add-notifications`)

## Success Criteria

- [ ] Kitchen display shows orders in real-time
- [ ] Two browser tabs show synchronized updates
- [ ] Presence shows active users
- [ ] Order tracker updates without refresh
- [ ] Order form validates items in real-time
- [ ] All LiveView tests pass
- [ ] `mix precommit` passes

## Technical Notes

- Kitchen Display uses `Phoenix.PubSub.subscribe` in `mount/3`
- Use `Phoenix.PubSub.broadcast` in `Orderflow.Orders` after successful transitions
- Presence uses `Phoenix.Presence` with `OrderflowWeb.Presence` module
- Kitchen display optimized for tablets (responsive Tailwind)
- Order form uses `LiveComponent` for line items
- Use `OrderflowWeb.Plugs.RequireRole` to ensure only chefs can access kitchen display
